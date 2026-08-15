#!/bin/sh
# install-llama-cpp-cuda.sh — quick llama.cpp setup on Void Linux + NVIDIA GPU
#
# What it does:
#   1. Checks nvidia-smi / driver
#   2. Installs Void build deps (cmake, gcc, ninja, …) via xbps
#   3. Installs NVIDIA CUDA Toolkit (runfile) if nvcc is missing
#   4. Patches CUDA/glibc cospi noexcept clash when needed (glibc 2.41+)
#   5. Clones/updates llama.cpp and builds with GGML_CUDA=ON
#   6. Installs binaries to PREFIX (default: ~/.local)
#
# Usage:
#   ./scripts/install-llama-cpp-cuda.sh
#   ./scripts/install-llama-cpp-cuda.sh --skip-cuda-install --rebuild
#   CUDA_VERSION=13.0.0 ./scripts/install-llama-cpp-cuda.sh
#
# Notes:
#   - Void does not ship the full CUDA toolkit; uses NVIDIA runfile (toolkit only).
#   - glibc 2.41 + CUDA 12.8 hits cospi/sinpi noexcept errors — we patch headers
#     or prefer CUDA 13.0 when installing fresh.
set -eu

PREFIX="${PREFIX:-$HOME/.local}"
SRC_DIR="${SRC_DIR:-$HOME/src/llama.cpp}"
# Prefer 13.0 with driver 595 (reports CUDA 13.2). Override with CUDA_VERSION=…
CUDA_VERSION="${CUDA_VERSION:-13.0.0}"
CUDA_HOME="${CUDA_HOME:-/usr/local/cuda}"
JOBS="${JOBS:-$(nproc 2>/dev/null || echo 4)}"
REPO_URL="${REPO_URL:-https://github.com/ggml-org/llama.cpp.git}"

SKIP_CUDA_INSTALL=0
REBUILD=0
for arg in "$@"; do
	case "$arg" in
	--skip-cuda-install) SKIP_CUDA_INSTALL=1 ;;
	--rebuild) REBUILD=1 ;;
	-h | --help)
		sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'
		exit 0
		;;
	*)
		printf 'Unknown option: %s (try --help)\n' "$arg" >&2
		exit 1
		;;
	esac
done

log() { printf '==> %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }
need_cmd() { command -v "$1" >/dev/null 2>&1 || die "missing command: $1"; }
have_pkg() { xbps-query -p pkgver "$1" >/dev/null 2>&1; }

run_root() {
	if [ "$(id -u)" -eq 0 ]; then
		"$@"
	elif command -v sudo >/dev/null 2>&1; then
		sudo "$@"
	else
		die "need root for: $*"
	fi
}

# --- 0. GPU ------------------------------------------------------------------
log "Checking NVIDIA GPU"
need_cmd nvidia-smi
nvidia-smi -L || die "nvidia-smi failed — install proprietary NVIDIA driver first"
nvidia-smi | head -n 12 || true

if [ ! -f /etc/os-release ] || ! grep -qi void /etc/os-release 2>/dev/null; then
	log "WARN: script is tuned for Void Linux (xbps)"
fi

# --- 1. Void packages (only missing) -----------------------------------------
install_void_deps() {
	log "Ensuring Void build dependencies"
	_want="cmake git gcc make pkg-config ninja libcurl-devel openssl-devel libgomp-devel"
	_need=""
	for p in $_want; do
		# gcc package provides g++; libgomp-devel for OpenMP
		if ! have_pkg "$p"; then
			_need="$_need $p"
		fi
	done
	# gcc-c++ may be separate on some systems; on Void, gcc usually pulls it
	if ! command -v g++ >/dev/null 2>&1; then
		_need="$_need gcc"
	fi
	if [ -z "$_need" ]; then
		log "All listed packages already installed"
		return 0
	fi
	log "Installing:$_need"
	# shellcheck disable=SC2086
	run_root xbps-install -Sy $_need || die "xbps-install failed"
}

install_void_deps
need_cmd git
need_cmd cmake
need_cmd g++
need_cmd ninja

# --- 2. CUDA -----------------------------------------------------------------
find_nvcc() {
	if command -v nvcc >/dev/null 2>&1; then
		command -v nvcc
		return 0
	fi
	for d in \
		"$CUDA_HOME/bin/nvcc" \
		/usr/local/cuda/bin/nvcc \
		/usr/local/cuda-13.0/bin/nvcc \
		/usr/local/cuda-12.9/bin/nvcc \
		/usr/local/cuda-12.8/bin/nvcc
	do
		[ -x "$d" ] && { printf '%s\n' "$d"; return 0; }
	done
	return 1
}

setup_cuda_env() {
	_nvcc=$(find_nvcc) || return 1
	_bindir=$(CDPATH= cd -- "$(dirname "$_nvcc")" && pwd)
	_root=$(CDPATH= cd -- "$_bindir/.." && pwd)
	export CUDA_HOME="$_root"
	export PATH="$_bindir:${PATH}"
	if [ -d "$_root/lib64" ]; then
		export LD_LIBRARY_PATH="$_root/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
	elif [ -d "$_root/targets/x86_64-linux/lib" ]; then
		export LD_LIBRARY_PATH="$_root/targets/x86_64-linux/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
	fi
	log "Using CUDA_HOME=$CUDA_HOME"
	nvcc --version | head -n 5 || true
}

# glibc 2.41+ declares cospi/sinpi with noexcept; CUDA ≤12.8 host headers do not.
# That breaks nvcc host preprocessor. Patch CUDA headers to add noexcept.
fix_cuda_glibc_cospi() {
	_hdr=""
	for h in \
		"$CUDA_HOME/targets/x86_64-linux/include/crt/math_functions.h" \
		"$CUDA_HOME/include/crt/math_functions.h" \
		/usr/local/cuda/targets/x86_64-linux/include/crt/math_functions.h
	do
		if [ -f "$h" ]; then
			_hdr=$h
			break
		fi
	done
	[ -n "$_hdr" ] || {
		log "WARN: math_functions.h not found — skip glibc patch"
		return 0
	}

	# Already patched?
	if grep -q 'sinpi(double x) noexcept' "$_hdr" 2>/dev/null; then
		log "CUDA glibc cospi patch already applied"
		return 0
	fi

	# Only needed when glibc exposes cospi with noexcept (2.41+)
	if ! grep -q 'cospi' /usr/include/bits/mathcalls.h 2>/dev/null; then
		log "glibc has no cospi in mathcalls.h — skip patch"
		return 0
	fi

	log "Patching CUDA headers for glibc cospi/sinpi noexcept clash"
	log "  file: $_hdr"
	_bak="${_hdr}.bak-atelier-glibc"
	if [ ! -f "$_bak" ]; then
		run_root cp -a "$_hdr" "$_bak"
	fi

	# Patch device-builtin declarations (CUDA 12.8 layout; spaces vary)
	run_root sed -E -i \
		-e 's/\b(sinpi|sinpif|cospi|cospif)\((float|double) x\);/\1(\2 x) noexcept;/g' \
		"$_hdr"

	if grep -Eq 'sinpi\(double x\) noexcept' "$_hdr"; then
		log "Patch applied OK"
	else
		log "WARN: patch may not have matched — install CUDA 13.0+ or patch manually:"
		log "  sudo sed -E -i.bak 's/\\b(sinpi|sinpif|cospi|cospif)\\((float|double) x\\);/\\1(\\2 x) noexcept;/g' $_hdr"
	fi
}

probe_cuda_url() {
	_ver=$1
	_base="https://developer.download.nvidia.com/compute/cuda/${_ver}/local_installers"
	# Known good build ids (order matters)
	for build in \
		580.65.06 \
		575.57.08 \
		570.124.06 \
		570.133.20 \
		570.148.08 \
		570.86.15 \
		570.86.10 \
		560.35.05
	do
		_cand="${_base}/cuda_${_ver}_${build}_linux.run"
		_code=$(curl -fsIL -o /dev/null -w '%{http_code}' "$_cand" 2>/dev/null || echo 000)
		if [ "$_code" = "200" ]; then
			printf '%s\n' "$_cand"
			return 0
		fi
	done
	_cand="${_base}/cuda_${_ver}_linux.run"
	_code=$(curl -fsIL -o /dev/null -w '%{http_code}' "$_cand" 2>/dev/null || echo 000)
	if [ "$_code" = "200" ]; then
		printf '%s\n' "$_cand"
		return 0
	fi
	return 1
}

install_cuda_toolkit() {
	log "Installing NVIDIA CUDA toolkit $CUDA_VERSION (runfile, toolkit only)"
	_tmpdir="${TMPDIR:-/tmp}/atelier-cuda-install"
	mkdir -p "$_tmpdir"
	_url="${CUDA_INSTALLER_URL:-}"
	if [ -z "$_url" ]; then
		log "Resolving runfile URL for $CUDA_VERSION …"
		_url=$(probe_cuda_url "$CUDA_VERSION") || true
	fi
	if [ -z "$_url" ]; then
		die "could not resolve CUDA $CUDA_VERSION runfile (set CUDA_INSTALLER_URL=…)"
	fi

	_dest="$_tmpdir/$(basename "$_url")"
	if [ ! -f "$_dest" ]; then
		log "Downloading $_url"
		curl -fL --progress-bar -o "$_dest" "$_url" || die "download failed"
	else
		log "Reusing $_dest"
	fi
	chmod +x "$_dest"

	log "Running installer (sudo; silent; does not replace GPU driver)"
	run_root sh "$_dest" --silent --toolkit --no-opengl-libs --override \
		|| die "CUDA runfile failed"

	if [ ! -x /usr/local/cuda/bin/nvcc ]; then
		_latest=$(ls -d /usr/local/cuda-* 2>/dev/null | sort -V | tail -n1 || true)
		if [ -n "$_latest" ] && [ -x "$_latest/bin/nvcc" ]; then
			log "Linking /usr/local/cuda → $_latest"
			run_root ln -sfn "$_latest" /usr/local/cuda
		fi
	fi
	CUDA_HOME=/usr/local/cuda
}

if setup_cuda_env; then
	log "nvcc already available"
elif [ "$SKIP_CUDA_INSTALL" -eq 1 ]; then
	die "nvcc not found and --skip-cuda-install was set"
else
	install_cuda_toolkit
	setup_cuda_env || die "nvcc still missing after toolkit install"
fi

# Always try the glibc patch (no-op if already fixed / not needed)
fix_cuda_glibc_cospi

# Quick host-compile probe
log "Probing nvcc host compile"
_probe="${TMPDIR:-/tmp}/atelier-cuda-probe-$$.cu"
printf 'int main(){return 0;}\n' >"$_probe"
if ! nvcc -c "$_probe" -o "${_probe}.o" 2>/tmp/atelier-nvcc-probe.log; then
	log "nvcc probe failed — applying glibc patch again / see /tmp/atelier-nvcc-probe.log"
	if grep -q 'cospi\|sinpi' /tmp/atelier-nvcc-probe.log 2>/dev/null; then
		fix_cuda_glibc_cospi
		nvcc -c "$_probe" -o "${_probe}.o" 2>/tmp/atelier-nvcc-probe.log \
			|| die "nvcc still broken after patch (try CUDA_VERSION=13.0.0 reinstall)"
	else
		die "nvcc probe failed (see /tmp/atelier-nvcc-probe.log)"
	fi
fi
rm -f "$_probe" "${_probe}.o"
log "nvcc probe OK"

# --- 3. Clone llama.cpp ------------------------------------------------------
log "Source tree: $SRC_DIR"
mkdir -p "$(dirname "$SRC_DIR")"
if [ -d "$SRC_DIR/.git" ]; then
	log "Updating existing clone"
	git -C "$SRC_DIR" pull --ff-only 2>/dev/null \
		|| git -C "$SRC_DIR" fetch --depth 1 origin master 2>/dev/null \
		|| true
else
	log "Cloning $REPO_URL"
	git clone --depth 1 "$REPO_URL" "$SRC_DIR"
fi

# --- 4. Build ----------------------------------------------------------------
cd "$SRC_DIR"
if [ "$REBUILD" -eq 1 ] && [ -d build ]; then
	log "Removing build/ (--rebuild)"
	rm -rf build
fi
# Stale failed configure leaves a broken cache — always wipe if no successful build
if [ -d build ] && [ ! -f build/build.ninja ] && [ ! -f build/Makefile ]; then
	log "Removing incomplete build/"
	rm -rf build
fi

_arch="${CMAKE_CUDA_ARCHITECTURES:-native}"
log "Configuring CMake (GGML_CUDA=ON, arch=$_arch)"

# Note: LLAMA_CURL is deprecated in recent llama.cpp — curl is enabled by default
# when libcurl is found. Do not pass -DLLAMA_CURL=ON.
_cmake_cfg() {
	_a=$1
	cmake -S . -B build -G Ninja \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX="$PREFIX" \
		-DGGML_CUDA=ON \
		-DGGML_NATIVE=ON \
		-DGGML_CCACHE=OFF \
		-DCMAKE_CUDA_ARCHITECTURES="$_a" \
		-DCMAKE_CUDA_COMPILER="$(command -v nvcc)"
}

if ! _cmake_cfg "$_arch"; then
	log "Configure failed — clean + retry with explicit SM list (incl. 89 for 40-series)"
	rm -rf build
	# Re-apply patch in case configure wiped nothing but we need fresh state
	fix_cuda_glibc_cospi
	_cmake_cfg "75;80;86;89;90" || die "cmake configure failed"
fi

log "Building (jobs=$JOBS) — first CUDA build can take a long time"
cmake --build build --config Release -j"$JOBS" || die "build failed"

log "Installing to $PREFIX"
cmake --install build

mkdir -p "$PREFIX/bin" "$PREFIX/share"
_envfile="$PREFIX/share/atelier-llama-cpp-env.sh"
# Include PREFIX/lib64 — llama installs many .so next to the install prefix
# (libllama-cli-impl.so, libggml-cuda.so, …). Without this you get:
#   error while loading shared libraries: libllama-cli-impl.so: cannot open …
cat >"$_envfile" <<EOF
# Generated by install-llama-cpp-cuda.sh — source from ~/.bashrc
export CUDA_HOME="${CUDA_HOME}"
export PATH="\${CUDA_HOME}/bin:${PREFIX}/bin:\${PATH}"
_libs=""
for _d in \\
  "${PREFIX}/lib64" \\
  "${PREFIX}/lib" \\
  "\${CUDA_HOME}/lib64" \\
  "\${CUDA_HOME}/targets/x86_64-linux/lib"
do
  if [ -d "\$_d" ]; then
    case ":\${_libs}:" in
      *":\${_d}:"*) ;;
      *) _libs="\${_libs}\${_libs:+:}\${_d}" ;;
    esac
  fi
done
export LD_LIBRARY_PATH="\${_libs}\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
unset _libs _d
EOF
log "Env helper: $_envfile  (source from ~/.bashrc if desired)"

# shellcheck source=/dev/null
. "$_envfile"

log "Smoke test"
if [ -x "$PREFIX/bin/llama-cli" ]; then
	"$PREFIX/bin/llama-cli" -h 2>&1 | head -n 8 || true
elif [ -x "$SRC_DIR/build/bin/llama-cli" ]; then
	"$SRC_DIR/build/bin/llama-cli" -h 2>&1 | head -n 8 || true
	log "Also available under $SRC_DIR/build/bin"
else
	log "Listing build/bin:"
	ls -la "$SRC_DIR/build/bin" 2>/dev/null | head -n 40 || true
fi

cat <<EOF

========================================================================
  llama.cpp CUDA build finished
========================================================================
  Source:  $SRC_DIR
  Prefix:  $PREFIX
  CUDA:    $CUDA_HOME

  source $_envfile
  llama-cli -m /path/to/model.gguf -ngl 99 -p "Hello"

  Rebuild:  $0 --rebuild --skip-cuda-install
========================================================================
EOF

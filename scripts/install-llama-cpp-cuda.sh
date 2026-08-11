#!/bin/sh
# install-llama-cpp-cuda.sh — quick llama.cpp setup on Void Linux + NVIDIA GPU
#
# What it does:
#   1. Checks nvidia-smi / driver
#   2. Installs Void build deps (cmake, gcc, git, …) via xbps
#   3. Installs NVIDIA CUDA Toolkit (runfile) if nvcc is missing
#   4. Clones/updates llama.cpp and builds with GGML_CUDA=ON
#   5. Installs binaries to PREFIX (default: ~/.local)
#   6. Writes a tiny env helper and runs a GPU smoke test
#
# Usage:
#   ./scripts/install-llama-cpp-cuda.sh
#   PREFIX=$HOME/.local CUDA_VERSION=12.8.1 ./scripts/install-llama-cpp-cuda.sh
#   ./scripts/install-llama-cpp-cuda.sh --skip-cuda-install   # if nvcc already OK
#   ./scripts/install-llama-cpp-cuda.sh --rebuild             # force clean rebuild
#
# Notes:
#   - Official Void repos do not ship the full CUDA toolkit; this uses NVIDIA's
#     Linux runfile (toolkit only — your existing proprietary driver stays).
#   - Needs network, several GB free disk, and sudo for packages / toolkit.
#   - RTX 40-series (e.g. 4060 Ti) = CUDA arch 89; we use "native" when possible.
set -eu

# --- defaults ----------------------------------------------------------------
PREFIX="${PREFIX:-$HOME/.local}"
SRC_DIR="${SRC_DIR:-$HOME/src/llama.cpp}"
# CUDA toolkit version to fetch if nvcc is missing (must be ≤ driver-supported)
# Driver 595 reports max CUDA 13.2; 12.8 is widely tested with llama.cpp.
CUDA_VERSION="${CUDA_VERSION:-12.8.1}"
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
		sed -n '2,28p' "$0" | sed 's/^# \{0,1\}//'
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

# --- 0. GPU / OS checks ------------------------------------------------------
log "Checking NVIDIA GPU"
need_cmd nvidia-smi
nvidia-smi -L || die "nvidia-smi failed — install/load proprietary NVIDIA driver first"
nvidia-smi | head -n 15 || true

if [ ! -f /etc/os-release ] || ! grep -qi void /etc/os-release 2>/dev/null; then
	log "WARN: this script targets Void Linux (xbps); continuing anyway"
fi

# --- 1. Void build packages --------------------------------------------------
install_void_deps() {
	log "Installing Void build dependencies (needs sudo)"
	# core build + curl (optional model fetch helpers)
	_pkgs="cmake git gcc gcc-c++ make pkg-config ninja libcurl-devel openssl-devel"
	# shellcheck disable=SC2086
	if command -v sudo >/dev/null 2>&1; then
		sudo xbps-install -Sy $_pkgs || die "xbps-install failed"
	else
		xbps-install -Sy $_pkgs || die "xbps-install failed (need root)"
	fi
}

need_cmd git
if ! command -v cmake >/dev/null 2>&1 || ! command -v g++ >/dev/null 2>&1; then
	install_void_deps
else
	log "cmake/g++ present — ensuring full dep set"
	install_void_deps
fi
need_cmd cmake
need_cmd g++

# --- 2. CUDA toolkit ---------------------------------------------------------
find_nvcc() {
	if command -v nvcc >/dev/null 2>&1; then
		command -v nvcc
		return 0
	fi
	for d in \
		"$CUDA_HOME/bin/nvcc" \
		/usr/local/cuda/bin/nvcc \
		/usr/local/cuda-12.8/bin/nvcc \
		/usr/local/cuda-12.6/bin/nvcc \
		/usr/local/cuda-13.0/bin/nvcc
	do
		if [ -x "$d" ]; then
			printf '%s\n' "$d"
			return 0
		fi
	done
	return 1
}

setup_cuda_env() {
	_nvcc=$(find_nvcc) || return 1
	_bindir=$(CDPATH= cd -- "$(dirname "$_nvcc")" && pwd)
	_root=$(CDPATH= cd -- "$_bindir/.." && pwd)
	export CUDA_HOME="$_root"
	export PATH="$_bindir:${PATH}"
	# common lib path
	if [ -d "$_root/lib64" ]; then
		export LD_LIBRARY_PATH="$_root/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
	fi
	log "Using CUDA_HOME=$CUDA_HOME"
	nvcc --version | head -n 5 || true
}

install_cuda_toolkit() {
	log "CUDA toolkit (nvcc) not found — installing NVIDIA toolkit $CUDA_VERSION (runfile)"
	log "This downloads a large installer (~3GB+). Driver is NOT replaced (--toolkit only)."

	_tmpdir="${TMPDIR:-/tmp}/atelier-cuda-install"
	mkdir -p "$_tmpdir"
	_runfile="cuda_${CUDA_VERSION}_linux.run"
	# NVIDIA layout: https://developer.download.nvidia.com/compute/cuda/12.8.1/local_installers/...
	# Some versions use a build suffix; try common patterns.
	_base="https://developer.download.nvidia.com/compute/cuda/${CUDA_VERSION}/local_installers"
	_url="${CUDA_INSTALLER_URL:-}"

	if [ -z "$_url" ]; then
		# Probe a few known filename patterns (NVIDIA renames with driver build id)
		log "Resolving CUDA runfile URL for $CUDA_VERSION …"
		# Use the network installer meta page is hard; prefer pinned URLs users can override.
		# 12.8.1 known local installer name (may 404 if NVIDIA renames — set CUDA_INSTALLER_URL).
		# Prefer known-good filenames (NVIDIA embeds a driver build id in the name)
		for cand in \
			"${_base}/cuda_${CUDA_VERSION}_570.124.06_linux.run" \
			"${_base}/cuda_${CUDA_VERSION}_570.86.15_linux.run" \
			"${_base}/cuda_${CUDA_VERSION}_570.86.10_linux.run" \
			"${_base}/cuda_${CUDA_VERSION}_560.35.05_linux.run" \
			"${_base}/cuda_${CUDA_VERSION}_linux.run"
		do
			# Follow redirects; NVIDIA often 302 → CDN
			_code=$(curl -fsIL -o /dev/null -w '%{http_code}' "$cand" 2>/dev/null || echo 000)
			if [ "$_code" = "200" ]; then
				_url=$cand
				break
			fi
		done
	fi

	if [ -z "$_url" ]; then
		cat >&2 <<EOF
error: could not auto-resolve CUDA $CUDA_VERSION runfile URL.

Install the CUDA toolkit manually (toolkit only, do not overwrite the driver), then re-run:

  # Example — get the runfile from:
  #   https://developer.nvidia.com/cuda-downloads
  #   Linux → x86_64 → runfile (local)
  sudo sh cuda_*_linux.run --silent --toolkit --no-opengl-libs --override

  export CUDA_HOME=/usr/local/cuda
  export PATH=\$CUDA_HOME/bin:\$PATH

Or re-run this script with an explicit URL:

  CUDA_INSTALLER_URL='https://developer.download.nvidia.com/compute/cuda/.../cuda_....run' \\
    $0 --skip-cuda-install   # after manual install
  # or without --skip if nvcc is still missing and URL is set:
  CUDA_INSTALLER_URL='...' $0

EOF
		die "CUDA toolkit missing"
	fi

	_dest="$_tmpdir/$(basename "$_url")"
	if [ ! -f "$_dest" ]; then
		log "Downloading $_url"
		curl -fL --progress-bar -o "$_dest" "$_url" || die "download failed"
	else
		log "Reusing cached installer $_dest"
	fi
	chmod +x "$_dest"

	log "Installing toolkit to /usr/local/cuda (sudo; silent)"
	# --toolkit: toolkit only; --no-opengl-libs: don't touch GL; skip driver
	if command -v sudo >/dev/null 2>&1; then
		sudo sh "$_dest" --silent --toolkit --no-opengl-libs --override \
			|| die "CUDA runfile failed"
	else
		sh "$_dest" --silent --toolkit --no-opengl-libs --override \
			|| die "CUDA runfile failed"
	fi

	# Symlink convenience
	if [ -d /usr/local/cuda ] && [ ! -e "$CUDA_HOME" ]; then
		CUDA_HOME=/usr/local/cuda
	fi
	# NVIDIA often installs to /usr/local/cuda-X.Y
	if [ ! -x "${CUDA_HOME}/bin/nvcc" ]; then
		_latest=$(ls -d /usr/local/cuda-* 2>/dev/null | sort -V | tail -n1 || true)
		if [ -n "$_latest" ] && [ -x "$_latest/bin/nvcc" ]; then
			CUDA_HOME=$_latest
			if [ ! -e /usr/local/cuda ]; then
				log "Linking /usr/local/cuda → $CUDA_HOME"
				if command -v sudo >/dev/null 2>&1; then
					sudo ln -sfn "$CUDA_HOME" /usr/local/cuda
				else
					ln -sfn "$CUDA_HOME" /usr/local/cuda
				fi
				CUDA_HOME=/usr/local/cuda
			fi
		fi
	fi
}

if setup_cuda_env; then
	log "nvcc already available"
elif [ "$SKIP_CUDA_INSTALL" -eq 1 ]; then
	die "nvcc not found and --skip-cuda-install was set"
else
	install_cuda_toolkit
	setup_cuda_env || die "nvcc still missing after toolkit install"
fi

# --- 3. Clone / update llama.cpp ---------------------------------------------
log "Source tree: $SRC_DIR"
mkdir -p "$(dirname "$SRC_DIR")"
if [ -d "$SRC_DIR/.git" ]; then
	log "Updating existing clone"
	git -C "$SRC_DIR" fetch --depth 1 origin master 2>/dev/null \
		|| git -C "$SRC_DIR" fetch --depth 1 origin main 2>/dev/null \
		|| true
	git -C "$SRC_DIR" pull --ff-only 2>/dev/null || true
else
	log "Cloning $REPO_URL"
	git clone --depth 1 "$REPO_URL" "$SRC_DIR"
fi

# --- 4. Configure & build with CUDA ------------------------------------------
cd "$SRC_DIR"
if [ "$REBUILD" -eq 1 ] && [ -d build ]; then
	log "Clean rebuild (--rebuild)"
	rm -rf build
fi

log "Configuring CMake (GGML_CUDA=ON)"
# native arch = detect GPU (4060 Ti → 89). Fallback: common 70;75;80;86;89;90
_arch="${CMAKE_CUDA_ARCHITECTURES:-native}"
cmake -S . -B build -G Ninja \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="$PREFIX" \
	-DGGML_CUDA=ON \
	-DGGML_NATIVE=ON \
	-DLLAMA_CURL=ON \
	-DCMAKE_CUDA_ARCHITECTURES="$_arch" \
	-DCMAKE_CUDA_COMPILER="$(command -v nvcc)" \
	|| {
		log "native arch failed — retrying common SM list"
		cmake -S . -B build -G Ninja \
			-DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_INSTALL_PREFIX="$PREFIX" \
			-DGGML_CUDA=ON \
			-DLLAMA_CURL=ON \
			-DCMAKE_CUDA_ARCHITECTURES="75;80;86;89;90" \
			-DCMAKE_CUDA_COMPILER="$(command -v nvcc)"
	}

log "Building (jobs=$JOBS) — first CUDA build can take a while"
cmake --build build --config Release -j"$JOBS"

log "Installing to $PREFIX"
cmake --install build

# Ensure user bin on PATH hint
mkdir -p "$PREFIX/bin"

# --- 5. Env helper -----------------------------------------------------------
_envfile="$PREFIX/share/atelier-llama-cpp-env.sh"
mkdir -p "$PREFIX/share"
cat >"$_envfile" <<EOF
# Generated by install-llama-cpp-cuda.sh — source from ~/.bashrc if you want
export CUDA_HOME="${CUDA_HOME}"
export PATH="${CUDA_HOME}/bin:${PREFIX}/bin:\${PATH}"
if [ -d "${CUDA_HOME}/lib64" ]; then
  export LD_LIBRARY_PATH="${CUDA_HOME}/lib64\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
fi
EOF
log "Wrote env helper: $_envfile"
log "Add permanently:  echo 'source $_envfile' >> ~/.bashrc"

# shellcheck source=/dev/null
. "$_envfile"

# --- 6. Smoke test -----------------------------------------------------------
log "Smoke test: llama-cli help + CUDA device list"
if command -v llama-cli >/dev/null 2>&1; then
	llama-cli --version 2>/dev/null || llama-cli -h 2>&1 | head -n 5 || true
elif [ -x "$PREFIX/bin/llama-cli" ]; then
	"$PREFIX/bin/llama-cli" -h 2>&1 | head -n 5 || true
elif [ -x "$SRC_DIR/build/bin/llama-cli" ]; then
	"$SRC_DIR/build/bin/llama-cli" -h 2>&1 | head -n 5 || true
	log "Binaries are also in $SRC_DIR/build/bin"
else
	# older binary name
	if [ -x "$SRC_DIR/build/bin/main" ]; then
		log "Found legacy build/bin/main"
	else
		log "WARN: could not find llama-cli — check $SRC_DIR/build/bin"
		ls -la "$SRC_DIR/build/bin" 2>/dev/null | head -n 30 || true
	fi
fi

# ggml-cuda presence
if ls "$SRC_DIR/build/bin"/libggml-cuda* >/dev/null 2>&1 \
	|| ls "$PREFIX/lib"/libggml-cuda* >/dev/null 2>&1 \
	|| ls "$PREFIX/lib64"/libggml-cuda* >/dev/null 2>&1; then
	log "CUDA backend library present"
else
	log "WARN: libggml-cuda not found in obvious paths — GPU offload may fail"
fi

cat <<EOF

========================================================================
  llama.cpp CUDA build finished
========================================================================

  Source:   $SRC_DIR
  Install:  $PREFIX  (llama-cli, llama-server, … in \$PREFIX/bin)
  CUDA:     $CUDA_HOME

  Load env for this shell:
    source $_envfile

  Run a GGUF model on GPU (offload all layers):
    llama-cli -m /path/to/model.gguf -ngl 99 -p "Hello"

  HTTP server:
    llama-server -m /path/to/model.gguf -ngl 99 --host 127.0.0.1 --port 8080

  Models: download any GGUF (e.g. from Hugging Face). Example:
    mkdir -p ~/models
    # then place a .gguf file there

  Rebuild later:
    $0 --rebuild --skip-cuda-install

  Your GPU: use nvidia-smi while a job runs to confirm VRAM usage.
========================================================================
EOF

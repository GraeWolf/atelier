#!/bin/sh
# Build the Atelier live ISO with void-mklive.
#
# Requirements:
#   - Void Linux host
#   - root privileges (void-mklive needs them)
#   - network (to fetch packages)
#   - disk space (several GB for cache + image)
#
# Usage:
#   sudo ./scripts/build-iso.sh              # full build
#   ./scripts/build-iso.sh --check           # validate prep without mklive (no root)
#   sudo ./scripts/build-iso.sh --skip-repo  # reuse existing repo/out
#
# Output: iso/output/atelier-<date>-x86_64.iso (path printed at end)
#
# Does NOT write/burn to disks. See AGENTS.md.
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
# shellcheck source=lib/atelier-common.sh
. "$SCRIPT_DIR/lib/atelier-common.sh"

ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
ISO_DIR="$ROOT/iso"
MKLIVE_DIR="${MKLIVE_DIR:-$ISO_DIR/void-mklive}"
MKLIVE_URL="${MKLIVE_URL:-https://github.com/void-linux/void-mklive.git}"
OUT_DIR="$ISO_DIR/output"
CACHE_DIR="${CACHE_DIR:-$ISO_DIR/work/xbps-cache}"
ARCH="${ARCH:-x86_64}"
TITLE="${TITLE:-Atelier Linux}"
DATE_STAMP=$(date +%Y%m%d)
OUT_ISO="$OUT_DIR/atelier-${DATE_STAMP}-${ARCH}.iso"

CHECK_ONLY=0
BUILD_REPO=1
for arg in "$@"; do
	case "$arg" in
	--check) CHECK_ONLY=1 ;;
	--skip-repo) BUILD_REPO=0 ;;
	-h | --help)
		sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
		exit 0
		;;
	*)
		atelier_die "unknown argument: $arg"
		;;
	esac
done

list_packages() {
	# Collapse package-lists/live.txt into a single line for mklive -p
	grep -v '^#' "$ISO_DIR/package-lists/live.txt" | grep -v '^[[:space:]]*$' | tr '\n' ' '
}

ensure_mklive() {
	if [ -x "$MKLIVE_DIR/mklive.sh" ]; then
		atelier_info "Using existing void-mklive at $MKLIVE_DIR"
		return 0
	fi
	atelier_info "Cloning void-mklive into $MKLIVE_DIR"
	mkdir -p "$(dirname "$MKLIVE_DIR")"
	git clone --depth 1 "$MKLIVE_URL" "$MKLIVE_DIR"
	# Some setups need make for README only; mklive.sh is usually ready
	if [ ! -x "$MKLIVE_DIR/mklive.sh" ]; then
		chmod +x "$MKLIVE_DIR/mklive.sh" 2>/dev/null || true
	fi
	[ -f "$MKLIVE_DIR/mklive.sh" ] || atelier_die "mklive.sh missing after clone"
}

check_host_tools() {
	_missing=""
	for c in git xbps-install xbps-query xbps-create xbps-rindex; do
		command -v "$c" >/dev/null 2>&1 || _missing="$_missing $c"
	done
	if [ -n "$_missing" ]; then
		atelier_die "missing host tools:$_missing"
	fi
	# mklive runtime deps (warn in --check, hard fail on real build)
	_mklive_deps="xorriso mksquashfs xz"
	_mklive_missing=""
	for c in $_mklive_deps; do
		command -v "$c" >/dev/null 2>&1 || _mklive_missing="$_mklive_missing $c"
	done
	if [ -n "$_mklive_missing" ]; then
		if [ "$CHECK_ONLY" -eq 1 ]; then
			atelier_info "WARN: mklive tools not installed:$_mklive_missing"
			atelier_info "      install e.g. xorriso squashfs-tools xz"
		else
			atelier_die "missing mklive tools:$_mklive_missing (xbps-install -S xorriso squashfs-tools xz)"
		fi
	fi
}

check_packages_resolvable() {
	# Best-effort: ensure atelier packages exist in local repo
	atelier_info "Checking personal packages in repo/out"
	for p in atelier-base atelier-config atelier-desktop atelier-void-repo; do
		xbps-query --repository="$ROOT/repo/out" -R "$p" >/dev/null 2>&1 || \
			atelier_die "cannot query $p from repo/out — run ./scripts/build-repo.sh"
	done
	# Best-effort: GraeWolf remote repo reachable (key/conf live on medium either way)
	if xbps-query --repository="https://github.com/GraeWolf/void-repo/releases/download/x86_64" \
		-R brave-origin >/dev/null 2>&1; then
		atelier_info "GraeWolf void-repo OK (brave-origin visible)"
	else
		atelier_info "WARN: cannot query brave-origin from GraeWolf void-repo (network?)"
	fi
}

run_mklive() {
	_pkgs=$(list_packages)
	_repo_out="$ROOT/repo/out"
	_include="$ISO_DIR/include"
	_post="$ISO_DIR/scripts/postsetup.sh"

	mkdir -p "$OUT_DIR" "$CACHE_DIR"

	atelier_info "Invoking mklive.sh (requires root)"
	atelier_info "  arch=$ARCH"
	atelier_info "  packages=$_pkgs"
	atelier_info "  output=$OUT_ISO"

	# shellcheck disable=SC2086
	cd "$MKLIVE_DIR"
	# Official Void + local Atelier packages + GraeWolf personal void-repo
	# (brave-origin, obsidian, …) so mklive can resolve those names if listed.
	./mklive.sh \
		-a "$ARCH" \
		-r "https://repo-default.voidlinux.org/current" \
		-r "$_repo_out" \
		-r "https://github.com/GraeWolf/void-repo/releases/download/x86_64" \
		-c "$CACHE_DIR" \
		-p "$_pkgs" \
		-I "$_include" \
		-S "dbus elogind NetworkManager" \
		-T "$TITLE" \
		-e /bin/bash \
		-x "$_post" \
		-o "$OUT_ISO"
	# Note: no live.autologin — live boots to TTY; run: sudo atelier-install
	# Optional desktop on live medium: startx (desktop packages still installed).
}

# --- main ---
check_host_tools

# Run non-mklive prep as the invoking user when under sudo so package FILESDIR
# and repo/out are not left root-owned.
run_as_builder() {
	if [ "$(id -u)" -eq 0 ] && [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != root ]; then
		sudo -u "$SUDO_USER" -- "$@"
	else
		"$@"
	fi
}

if [ "$BUILD_REPO" -eq 1 ]; then
	atelier_info "Building personal repository"
	run_as_builder "$ROOT/scripts/build-repo.sh"
else
	atelier_info "Skipping repo build (--skip-repo)"
fi

check_packages_resolvable
ensure_mklive
# Clone may be root-owned if ensure_mklive ran as root; prepare copies only.
run_as_builder "$ROOT/scripts/prepare-iso-include.sh" "$MKLIVE_DIR"

_pkgs=$(list_packages)
atelier_info "Package list: $_pkgs"

if [ "$CHECK_ONLY" -eq 1 ]; then
	atelier_info "Check mode: not running mklive (no ISO produced)"
	atelier_info "Include tree:"
	find "$ISO_DIR/include" -type f | sort | sed 's|^|  |'
	atelier_info "void-mklive: $MKLIVE_DIR"
	atelier_info "Would write: $OUT_ISO"
	atelier_info "Run for real: sudo ./scripts/build-iso.sh"
	exit 0
fi

if [ "$(id -u)" -ne 0 ]; then
	atelier_die "ISO build requires root. Re-run: sudo $0 $*"
fi

run_mklive

if [ -f "$OUT_ISO" ]; then
	atelier_info "ISO built: $OUT_ISO"
	ls -lh "$OUT_ISO"
else
	# mklive may choose a slightly different name; show output dir
	atelier_info "Build finished; contents of $OUT_DIR:"
	ls -lah "$OUT_DIR" || true
fi

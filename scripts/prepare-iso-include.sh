#!/bin/sh
# Prepare iso/include for void-mklive -I from include-src + personal repo packages.
# Optional: pass path to void-mklive checkout to embed void-installer.
#
# Usage:
#   ./scripts/prepare-iso-include.sh
#   ./scripts/prepare-iso-include.sh /path/to/void-mklive
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
# shellcheck source=lib/atelier-common.sh
. "$SCRIPT_DIR/lib/atelier-common.sh"

ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
SRC="$ROOT/iso/include-src"
DST="$ROOT/iso/include"
REPO_OUT="$ROOT/repo/out"
MKLIVE_DIR=${1:-${MKLIVE_DIR:-$ROOT/iso/void-mklive}}

[ -d "$SRC" ] || atelier_die "missing $SRC"

atelier_info "Preparing ISO include directory"
rm -rf "$DST"
mkdir -p "$DST"

# Copy static live overlay
cp -a "$SRC"/. "$DST/"

# Embed personal repository for live system updates / reinstall of Atelier pkgs
if [ ! -d "$REPO_OUT" ] || ! ls "$REPO_OUT"/*.xbps >/dev/null 2>&1; then
	atelier_info "repo/out empty — running build-repo.sh"
	"$ROOT/scripts/build-repo.sh"
fi

mkdir -p "$DST/usr/share/atelier/repo"
cp -a "$REPO_OUT"/. "$DST/usr/share/atelier/repo/"

# Temporary void-installer (from void-mklive) until custom GUI installer (Step 5)
if [ -f "$MKLIVE_DIR/installer.sh" ]; then
	atelier_info "Embedding void-installer from $MKLIVE_DIR"
	_ver="atelier"
	if [ -f "$MKLIVE_DIR/version" ]; then
		# shellcheck disable=SC1091
		_ver=$(cat "$MKLIVE_DIR/version" 2>/dev/null || echo atelier)
	fi
	mkdir -p "$DST/usr/bin"
	sed "s/@@MKLIVE_VERSION@@/${_ver}/" "$MKLIVE_DIR/installer.sh" >"$DST/usr/bin/void-installer"
	chmod 755 "$DST/usr/bin/void-installer"
else
	atelier_info "WARN: no installer.sh at $MKLIVE_DIR (void-installer not embedded)"
fi

# Sanity
[ -f "$DST/etc/xbps.d/10-repository-atelier.conf" ] || \
	atelier_die "missing atelier xbps.d in include"
ls "$DST/usr/share/atelier/repo"/*.xbps >/dev/null 2>&1 || \
	atelier_die "no .xbps packages copied into include repo"

atelier_info "Include ready: $DST"
find "$DST" -type f | sort | sed 's|^|  |'

#!/bin/sh
# Verify the local Atelier XBPS repository is queryable and installable.
#
# Usage:
#   ./scripts/verify-repo.sh
#   ./scripts/verify-repo.sh --root /tmp/atelier-test-root
#
# Default mode:
#   - queries all Atelier packages from repo/out
#   - installs atelier-base + atelier-config into a temporary rootdir
#     (uses official Void repo for transitive depends)
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
# shellcheck source=lib/atelier-common.sh
. "$SCRIPT_DIR/lib/atelier-common.sh"

ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
REPO_OUT="$ROOT/repo/out"
TARGET_ROOT=""
KEEP_ROOT=0
VOID_REPO="${VOID_REPO:-https://repo-default.voidlinux.org/current}"

while [ $# -gt 0 ]; do
	case "$1" in
	--root)
		shift
		TARGET_ROOT=${1:-}
		[ -n "$TARGET_ROOT" ] || atelier_die "--root requires a path"
		KEEP_ROOT=1
		;;
	--root=*)
		TARGET_ROOT=${1#--root=}
		KEEP_ROOT=1
		;;
	-h | --help)
		sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
		exit 0
		;;
	*)
		atelier_die "unknown argument: $1"
		;;
	esac
	shift
done

[ -d "$REPO_OUT" ] || atelier_die "missing $REPO_OUT — run scripts/build-repo.sh first"
ls "$REPO_OUT"/*.xbps >/dev/null 2>&1 || atelier_die "no .xbps files in $REPO_OUT"

atelier_info "Querying local repository"
xbps-query --repository="$REPO_OUT" -Rs 'atelier' || true

for pkg in atelier-base atelier-config atelier-desktop atelier-installer; do
	atelier_info "Metadata: $pkg"
	xbps-query --repository="$REPO_OUT" -R "$pkg" || atelier_die "cannot query $pkg"
done

# Install into a rootdir so we do not require host package DB write access.
if [ -z "$TARGET_ROOT" ]; then
	TARGET_ROOT=$(mktemp -d /tmp/atelier-repo-verify.XXXXXX)
	KEEP_ROOT=0
fi

atelier_info "Installing atelier-base + atelier-config into $TARGET_ROOT"
mkdir -p "$TARGET_ROOT/var/db/xbps/keys"
if [ -d /var/db/xbps/keys ]; then
	cp -a /var/db/xbps/keys/. "$TARGET_ROOT/var/db/xbps/keys/" 2>/dev/null || true
fi

xbps-install -r "$TARGET_ROOT" \
	--repository="$VOID_REPO" \
	--repository="$REPO_OUT" \
	-Sy atelier-base atelier-config

xbps-query -r "$TARGET_ROOT" -l | grep 'atelier-' || true

[ -f "$TARGET_ROOT/etc/skel/.xinitrc" ] || atelier_die "missing /etc/skel/.xinitrc"
[ -f "$TARGET_ROOT/etc/skel/.config/bspwm/bspwmrc" ] || atelier_die "missing bspwmrc"
[ -f "$TARGET_ROOT/usr/share/xsessions/atelier.desktop" ] || atelier_die "missing atelier.desktop"
[ -f "$TARGET_ROOT/etc/bash/bashrc.d/atelier.sh" ] || atelier_die "missing bashrc.d snippet"

atelier_info "Config files present under rootdir"

# Confirm desktop metapackage is resolvable (may download many packages — dry via query only)
atelier_info "Checking atelier-desktop dependency closure is visible"
xbps-query -r "$TARGET_ROOT" --repository="$VOID_REPO" --repository="$REPO_OUT" -R atelier-desktop >/dev/null

if [ "$KEEP_ROOT" -eq 0 ]; then
	rm -rf "$TARGET_ROOT"
	atelier_info "Removed temporary rootdir"
else
	atelier_info "Left rootdir in place: $TARGET_ROOT"
fi

atelier_info "Repository verification OK"

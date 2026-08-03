#!/bin/sh
# void-mklive -x postsetup: runs inside the build host with ROOTFS as $1
# Keep this script idempotent and free of secrets.
set -eu

ROOTFS=${1:-}
if [ -z "$ROOTFS" ] || [ ! -d "$ROOTFS" ]; then
	printf 'postsetup: ROOTFS missing or not a directory: %s\n' "$ROOTFS" >&2
	exit 1
fi

log() {
	printf 'atelier-postsetup: %s\n' "$*"
}

log "ROOTFS=$ROOTFS"

# Ensure personal repo dir exists even if include copy failed partially
mkdir -p "$ROOTFS/usr/share/atelier/repo"

# Live user gets skel configs from packages; ensure xinitrc is executable if present
if [ -f "$ROOTFS/etc/skel/.xinitrc" ]; then
	chmod 755 "$ROOTFS/etc/skel/.xinitrc"
fi
if [ -f "$ROOTFS/etc/skel/.config/bspwm/bspwmrc" ]; then
	chmod 755 "$ROOTFS/etc/skel/.config/bspwm/bspwmrc"
fi
if [ -f "$ROOTFS/etc/skel/.config/polybar/launch.sh" ]; then
	chmod 755 "$ROOTFS/etc/skel/.config/polybar/launch.sh"
fi

# Prefer NetworkManager on live images when present
if [ -d "$ROOTFS/etc/sv/NetworkManager" ]; then
	mkdir -p "$ROOTFS/etc/runit/runsvdir/default"
	ln -sfn /etc/sv/NetworkManager "$ROOTFS/etc/runit/runsvdir/default/NetworkManager" 2>/dev/null || true
fi

# Document image identity
mkdir -p "$ROOTFS/usr/share/atelier"
{
	printf 'Atelier Linux live image\n'
	printf 'Built with void-mklive wrappers in the Atelier monorepo.\n'
	if [ -f "$ROOTFS/usr/share/atelier/repo/x86_64-repodata" ] || \
		ls "$ROOTFS/usr/share/atelier/repo"/*.xbps >/dev/null 2>&1; then
		printf 'Personal repository: /usr/share/atelier/repo\n'
	fi
} >"$ROOTFS/usr/share/atelier/image-info.txt"

log "done"

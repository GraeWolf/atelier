#!/bin/sh
# Sync installer/ → packages/atelier-installer/files/
set -eu

root="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
src="$root/installer"
dst="$root/packages/atelier-installer/files"

[ -f "$src/atelier-install" ] || {
	printf 'error: missing %s/atelier-install\n' "$src" >&2
	exit 1
}
[ -f "$src/install.conf" ] || {
	printf 'error: missing %s/install.conf\n' "$src" >&2
	exit 1
}

if [ -d "$dst" ]; then
	if ! rm -rf "$dst" 2>/dev/null; then
		mv "$dst" "$dst.stale.$$" 2>/dev/null || {
			printf 'error: cannot replace %s (root-owned?). chown/remove and retry\n' "$dst" >&2
			exit 1
		}
	fi
fi
mkdir -p "$dst/usr/bin" "$dst/etc/atelier"

install -m 755 "$src/atelier-install" "$dst/usr/bin/atelier-install"
install -m 644 "$src/install.conf" "$dst/etc/atelier/install.conf"

printf 'Synced %s → %s\n' "$src" "$dst"

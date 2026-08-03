#!/bin/sh
# Sync configs/xlibre + helpers → packages/atelier-xlibre-repo/files/
set -eu

root="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
src="$root/configs/xlibre"
dst="$root/packages/atelier-xlibre-repo/files"
helpers="$root/packages/atelier-xlibre-repo/helpers"

[ -d "$src" ] || {
	printf 'error: missing %s\n' "$src" >&2
	exit 1
}

if [ -d "$dst" ]; then
	if ! rm -rf "$dst" 2>/dev/null; then
		mv "$dst" "$dst.stale.$$" 2>/dev/null || {
			printf 'error: cannot replace %s\n' "$dst" >&2
			exit 1
		}
	fi
fi

mkdir -p \
	"$dst/etc/xbps.d" \
	"$dst/var/db/xbps/keys" \
	"$dst/usr/bin" \
	"$dst/usr/share/doc/atelier"

install -m 644 "$src/xbps.d/99-repository-xlibre.conf" \
	"$dst/etc/xbps.d/99-repository-xlibre.conf"
install -m 644 "$src/xbps-keys/00:ca:42:57:c9:c0:9a:ec:94:b4:7d:97:e5:a9:aa:1e.plist" \
	"$dst/var/db/xbps/keys/00:ca:42:57:c9:c0:9a:ec:94:b4:7d:97:e5:a9:aa:1e.plist"
install -m 755 "$helpers/atelier-setup-xlibre" \
	"$dst/usr/bin/atelier-setup-xlibre"
install -m 644 "$helpers/xlibre-README.txt" \
	"$dst/usr/share/doc/atelier/xlibre-README.txt"

printf 'Synced Xlibre repo configs → %s\n' "$dst"

#!/bin/sh
# Sync packages/atelier-asus/helpers → packages/atelier-asus/files/
set -eu

root="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
helpers="$root/packages/atelier-asus/helpers"
dst="$root/packages/atelier-asus/files"

[ -d "$helpers" ] || {
	printf 'error: missing %s\n' "$helpers" >&2
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
	"$dst/usr/bin" \
	"$dst/etc/udev/rules.d" \
	"$dst/usr/share/doc/atelier"

install -m 755 "$helpers/atelier-kbd" \
	"$dst/usr/bin/atelier-kbd"
install -m 644 "$helpers/99-atelier-asus-kbd.rules" \
	"$dst/etc/udev/rules.d/99-atelier-asus-kbd.rules"
install -m 644 "$helpers/asus-README.txt" \
	"$dst/usr/share/doc/atelier/asus-README.txt"

printf 'Synced ASUS keyboard helpers → %s\n' "$dst"

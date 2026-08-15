#!/bin/sh
# Sync packages/atelier-windows-vm/helpers → packages/atelier-windows-vm/files/
set -eu

root="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
helpers="$root/packages/atelier-windows-vm/helpers"
dst="$root/packages/atelier-windows-vm/files"

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
	"$dst/usr/share/applications" \
	"$dst/usr/share/atelier/windows" \
	"$dst/usr/share/doc/atelier"

install -m 755 "$helpers/atelier-windows-vm" \
	"$dst/usr/bin/atelier-windows-vm"
install -m 755 "$helpers/atelier-setup-docker" \
	"$dst/usr/bin/atelier-setup-docker"
install -m 644 "$helpers/atelier-windows.desktop" \
	"$dst/usr/share/applications/atelier-windows.desktop"
install -m 644 "$helpers/docker-compose.yml.example" \
	"$dst/usr/share/atelier/windows/docker-compose.yml.example"
install -m 644 "$helpers/windows-vm-README.txt" \
	"$dst/usr/share/doc/atelier/windows-vm-README.txt"

printf 'Synced Windows VM helpers → %s\n' "$dst"

#!/bin/sh
# Sync configs/nvidia + helper scripts → packages/atelier-nvidia/files/
set -eu

root="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
src="$root/configs/nvidia"
dst="$root/packages/atelier-nvidia/files"
helpers="$root/packages/atelier-nvidia/helpers"

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
	"$dst/etc/modprobe.d" \
	"$dst/etc/modules-load.d" \
	"$dst/etc/dracut.conf.d" \
	"$dst/etc/X11/xorg.conf.d" \
	"$dst/usr/bin" \
	"$dst/usr/share/doc/atelier"

install -m 644 "$src/modprobe.d/atelier-blacklist-nouveau.conf" \
	"$dst/etc/modprobe.d/atelier-blacklist-nouveau.conf"
install -m 644 "$src/modprobe.d/atelier-nvidia.conf" \
	"$dst/etc/modprobe.d/atelier-nvidia.conf"
install -m 644 "$src/modules-load.d/atelier-nvidia.conf" \
	"$dst/etc/modules-load.d/atelier-nvidia.conf"
install -m 644 "$src/X11/xorg.conf.d/20-nvidia.conf" \
	"$dst/etc/X11/xorg.conf.d/20-nvidia.conf"
install -m 644 "$src/dracut.conf.d/atelier-nvidia.conf" \
	"$dst/etc/dracut.conf.d/atelier-nvidia.conf"
install -m 755 "$helpers/atelier-nvidia-grub" \
	"$dst/usr/bin/atelier-nvidia-grub"
# atelier-setup-nvidia ships in atelier-config so the command exists
# when NVIDIA was skipped at install time.
install -m 644 "$helpers/nvidia-README.txt" \
	"$dst/usr/share/doc/atelier/nvidia-README.txt"

printf 'Synced NVIDIA configs → %s\n' "$dst"

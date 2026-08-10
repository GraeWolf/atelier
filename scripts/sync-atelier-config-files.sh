#!/bin/sh
# Sync configs/ → packages/atelier-config/files/ for XBPS packaging.
# Canonical edits live under configs/. Run this before building atelier-config.
set -eu

root="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
src="$root/configs"
dst="$root/packages/atelier-config/files"

die() {
	printf '%s\n' "$*" >&2
	exit 1
}

[ -d "$src" ] || die "missing $src"

# Fresh install tree under files/ (keep template outside files/)
# Rename-aside if a previous root/sudo build left unremovable files.
if [ -d "$dst" ]; then
	if ! rm -rf "$dst" 2>/dev/null; then
		mv "$dst" "$dst.stale.$$" 2>/dev/null || die "cannot replace $dst (root-owned?). chown/remove and retry"
	fi
fi
mkdir -p "$dst"
mkdir -p \
	"$dst/etc/skel/.config/bspwm" \
	"$dst/etc/skel/.config/sxhkd" \
	"$dst/etc/skel/.config/picom" \
	"$dst/etc/skel/.config/polybar" \
	"$dst/etc/skel/.config/rofi" \
	"$dst/etc/skel/.config/ghostty" \
	"$dst/etc/skel/.config/nvim/lua" \
	"$dst/etc/skel/.config/fastfetch" \
	"$dst/etc/skel/.config/btop" \
	"$dst/etc/skel/.config/gtk-3.0" \
	"$dst/etc/skel/.config/gtk-4.0" \
	"$dst/etc/skel/.config/qt5ct/colors" \
	"$dst/etc/skel/.config/qt6ct/colors" \
	"$dst/etc/skel/.config/xsecurelock" \
	"$dst/etc/bash/bashrc.d" \
	"$dst/usr/share/xsessions" \
	"$dst/usr/share/doc/atelier" \
	"$dst/usr/share/atelier/wallpapers"

install -m 755 "$src/bspwm/bspwmrc"              "$dst/etc/skel/.config/bspwm/bspwmrc"
install -m 644 "$src/sxhkd/sxhkdrc"              "$dst/etc/skel/.config/sxhkd/sxhkdrc"
install -m 644 "$src/picom/picom.conf"           "$dst/etc/skel/.config/picom/picom.conf"
install -m 644 "$src/polybar/config.ini"         "$dst/etc/skel/.config/polybar/config.ini"
install -m 755 "$src/polybar/launch.sh"          "$dst/etc/skel/.config/polybar/launch.sh"
install -m 755 "$src/polybar/net-status.sh"      "$dst/etc/skel/.config/polybar/net-status.sh"
install -m 755 "$src/polybar/nmtui-float.sh"     "$dst/etc/skel/.config/polybar/nmtui-float.sh"
install -m 644 "$src/rofi/config.rasi"           "$dst/etc/skel/.config/rofi/config.rasi"
install -m 755 "$src/rofi/atelier-rofi.sh"       "$dst/etc/skel/.config/rofi/atelier-rofi.sh"
mkdir -p "$dst/etc/skel/.config/rofi/themes"
install -m 644 "$src/rofi/themes/tokyo-night.rasi" "$dst/etc/skel/.config/rofi/themes/tokyo-night.rasi"
mkdir -p "$dst/usr/bin" "$dst/usr/share/doc/atelier" \
	"$dst/etc/skel/.config/atelier"
install -m 755 "$src/rofi/atelier-rofi.sh"       "$dst/usr/bin/atelier-rofi"
install -m 755 "$src/session/atelier-monitors"   "$dst/usr/bin/atelier-monitors"
install -m 755 "$src/session/atelier-keybinds"   "$dst/usr/bin/atelier-keybinds"
install -m 755 "$src/session/atelier-lock"       "$dst/usr/bin/atelier-lock"
install -m 644 "$src/keybinds/cheatsheet.txt"    "$dst/usr/share/doc/atelier/keybinds.txt"
install -m 644 "$src/keybinds/cheatsheet.txt"    "$dst/etc/skel/.config/atelier/keybinds.txt"
install -m 644 "$src/ghostty/config"             "$dst/etc/skel/.config/ghostty/config"
# Neovim (voidwolf-based; plugins install on first launch via vim.pack)
install -m 644 "$src/nvim/init.lua"              "$dst/etc/skel/.config/nvim/init.lua"
install -m 644 "$src/nvim/nvim-pack-lock.json"   "$dst/etc/skel/.config/nvim/nvim-pack-lock.json"
install -m 644 "$src/nvim/lua/options.lua"       "$dst/etc/skel/.config/nvim/lua/options.lua"
install -m 644 "$src/nvim/lua/keymaps.lua"       "$dst/etc/skel/.config/nvim/lua/keymaps.lua"
install -m 644 "$src/nvim/lua/commands.lua"      "$dst/etc/skel/.config/nvim/lua/commands.lua"
install -m 644 "$src/nvim/lua/pack.lua"          "$dst/etc/skel/.config/nvim/lua/pack.lua"
install -m 644 "$src/nvim/lua/treesitter.lua"    "$dst/etc/skel/.config/nvim/lua/treesitter.lua"
install -m 644 "$src/nvim/lua/lsp.lua"           "$dst/etc/skel/.config/nvim/lua/lsp.lua"
install -m 644 "$src/starship/starship.toml"     "$dst/etc/skel/.config/starship.toml"
install -m 644 "$src/fastfetch/config.jsonc"     "$dst/etc/skel/.config/fastfetch/config.jsonc"
install -m 644 "$src/btop/btop.conf"             "$dst/etc/skel/.config/btop/btop.conf"
install -m 644 "$src/gtk/gtk-3.0/settings.ini"   "$dst/etc/skel/.config/gtk-3.0/settings.ini"
install -m 644 "$src/gtk/gtk-3.0/gtk.css"        "$dst/etc/skel/.config/gtk-3.0/gtk.css"
install -m 644 "$src/gtk/gtk-4.0/settings.ini"   "$dst/etc/skel/.config/gtk-4.0/settings.ini"
install -m 644 "$src/gtk/gtk-4.0/gtk.css"        "$dst/etc/skel/.config/gtk-4.0/gtk.css"
install -m 644 "$src/qt/qt5ct/qt5ct.conf"        "$dst/etc/skel/.config/qt5ct/qt5ct.conf"
install -m 644 "$src/qt/qt5ct/colors/tokyo-night.conf" \
	"$dst/etc/skel/.config/qt5ct/colors/tokyo-night.conf"
install -m 644 "$src/qt/qt6ct/qt6ct.conf"        "$dst/etc/skel/.config/qt6ct/qt6ct.conf"
install -m 644 "$src/qt/qt6ct/colors/tokyo-night.conf" \
	"$dst/etc/skel/.config/qt6ct/colors/tokyo-night.conf"
install -m 644 "$src/xsecurelock/env.sh"         "$dst/etc/skel/.config/xsecurelock/env.sh"
install -m 755 "$src/session/xinitrc"            "$dst/etc/skel/.xinitrc"
install -m 644 "$src/session/Xresources"         "$dst/etc/skel/.Xresources"
install -m 644 "$src/session/atelier.desktop"    "$dst/usr/share/xsessions/atelier.desktop"
install -m 644 "$src/shell/bashrc.d-atelier.sh"  "$dst/etc/bash/bashrc.d/atelier.sh"
install -m 644 "$src/colors/tokyo-night.conf"    "$dst/usr/share/doc/atelier/tokyo-night-palette.conf"
install -m 644 "$src/wallpapers/nord.png" \
	"$dst/usr/share/atelier/wallpapers/nord.png"
install -m 644 "$src/wallpapers/catppuccin-mocha.png" \
	"$dst/usr/share/atelier/wallpapers/catppuccin-mocha.png"

printf 'Synced %s → %s\n' "$src" "$dst"

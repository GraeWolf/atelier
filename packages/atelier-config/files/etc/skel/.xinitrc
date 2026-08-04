#!/bin/sh
# Atelier — default X session (~/.xinitrc)
# Starts a Tokyo Night themed bspwm desktop.

# Merge X resources
[ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"

# --- XDG runtime dir (required by rofi pid file, pipewire, etc.) -------------
# Plain startx often skips elogind's /run/user/$UID setup. Create a private
# runtime directory so clients can write pid/socket files.
if [ -z "${XDG_RUNTIME_DIR:-}" ] || [ ! -d "${XDG_RUNTIME_DIR}" ] || [ ! -w "${XDG_RUNTIME_DIR}" ]; then
	if [ -d "/run/user/$(id -u)" ] && [ -w "/run/user/$(id -u)" ]; then
		export XDG_RUNTIME_DIR="/run/user/$(id -u)"
	else
		export XDG_RUNTIME_DIR="${TMPDIR:-/tmp}/runtime-$(id -u)"
		mkdir -p "$XDG_RUNTIME_DIR"
		chmod 700 "$XDG_RUNTIME_DIR" 2>/dev/null || true
	fi
fi

# Qt: use qt5ct / qt6ct for theming
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_STYLE_OVERRIDE=

# GTK / icons (also set in settings.ini)
export GTK_THEME=Adwaita-dark
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=24

# --- VM / weak OpenGL help ---------------------------------------------------
# Ghostty and some GL clients render blank text under broken virtio/vbox GL.
# Force Mesa software rasterizer in known virtual machines (no-op needed on
# real GPUs if detection fails closed — we only set this for virt markers).
if [ -z "${LIBGL_ALWAYS_SOFTWARE:-}" ] && [ -z "${ATELIER_FORCE_HW_GL:-}" ]; then
	_virt=0
	if command -v systemd-detect-virt >/dev/null 2>&1; then
		# Works even without systemd as PID 1 on some systems; ignore failure
		systemd-detect-virt -q 2>/dev/null && _virt=1
	fi
	if [ "$_virt" -eq 0 ] && command -v lspci >/dev/null 2>&1; then
		if lspci 2>/dev/null | grep -qiE 'Virtio|VMware|VirtualBox|QEMU|Cirrus|Bochs|Standard VGA'; then
			_virt=1
		fi
	fi
	if [ "$_virt" -eq 0 ] && [ -r /sys/class/dmi/id/product_name ]; then
		if grep -qiE 'VirtualBox|VMware|QEMU|KVM|Bochs|Cloud|HVM' /sys/class/dmi/id/product_name 2>/dev/null; then
			_virt=1
		fi
	fi
	if [ "$_virt" -eq 1 ]; then
		export LIBGL_ALWAYS_SOFTWARE=1
		export GALLIUM_DRIVER="${GALLIUM_DRIVER:-llvmpipe}"
		export MESA_LOADER_DRIVER_OVERRIDE="${MESA_LOADER_DRIVER_OVERRIDE:-llvmpipe}"
	fi
fi
unset _virt

# xsecurelock environment
if [ -f "$HOME/.config/xsecurelock/env.sh" ]; then
	# shellcheck source=/dev/null
	. "$HOME/.config/xsecurelock/env.sh"
fi

# dbus session (runit / elogind systems usually already have this)
if command -v dbus-launch >/dev/null 2>&1 && [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
	eval "$(dbus-launch --sh-syntax --exit-with-session)"
fi

# Starship for interactive shells started from the session (bash/zsh rc also set this)
export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"

# Root window color (Tokyo Night bg)
xsetroot -solid "#1a1b26"

# Hand off to bspwm (must be last — replaces the shell)
exec bspwm

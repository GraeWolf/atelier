#!/bin/sh
# Atelier — default X session (~/.xinitrc)
# Starts a themed bspwm desktop (Tokyo Night unless atelier-theme selected another).

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

# GTK / icons — defaults, then overlay from atelier-theme if already applied
export GTK_THEME=Yaru-dark
export XCURSOR_THEME=Yaru
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

# xsecurelock environment (also re-sourced by atelier-lock)
if [ -f "$HOME/.config/xsecurelock/env.sh" ]; then
	# shellcheck source=/dev/null
	. "$HOME/.config/xsecurelock/env.sh"
fi

# Idle timeouts (MIT-SCREEN-SAVER → xss-lock → atelier-lock)
#   timeout  = seconds idle before lock (default 300 = 5 min)
#   cycle    = seconds for dimmer notifier before lock (default 30)
# Override: ATELIER_LOCK_IDLE_SEC / ATELIER_LOCK_CYCLE_SEC
# Suspend while locked: ATELIER_LOCK_SUSPEND_SEC (default 120; set 0 to disable)
if command -v xset >/dev/null 2>&1 && [ -z "${ATELIER_SKIP_IDLE_LOCK:-}" ]; then
	_idle=${ATELIER_LOCK_IDLE_SEC:-300}
	_cycle=${ATELIER_LOCK_CYCLE_SEC:-30}
	xset s "$_idle" "$_cycle"
	xset s blank
	# Prefer xss-lock idle path over DPMS races; leave DPMS off by default
	xset -dpms 2>/dev/null || true
	unset _idle _cycle
fi

# dbus session (runit / elogind systems usually already have this)
if command -v dbus-launch >/dev/null 2>&1 && [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
	eval "$(dbus-launch --sh-syntax --exit-with-session)"
fi

# ssh-agent: one agent for the whole X session (git push, ssh, etc.)
# Socket: $XDG_RUNTIME_DIR/ssh-agent.socket — also sourced from bashrc.d
if [ -f "$HOME/.config/ssh/agent-env.sh" ]; then
	# shellcheck source=/dev/null
	. "$HOME/.config/ssh/agent-env.sh"
fi

# Audio: PipeWire (+ session manager + PulseAudio compatibility for polybar/apps)
# Requires packages from atelier-desktop. Skip with ATELIER_SKIP_AUDIO=1.
if [ -z "${ATELIER_SKIP_AUDIO:-}" ] && command -v pipewire >/dev/null 2>&1; then
	pgrep -u "$(id -u)" -x pipewire >/dev/null 2>&1 || pipewire &
	if command -v wireplumber >/dev/null 2>&1; then
		pgrep -u "$(id -u)" -x wireplumber >/dev/null 2>&1 || wireplumber &
	fi
	if command -v pipewire-pulse >/dev/null 2>&1; then
		pgrep -u "$(id -u)" -x pipewire-pulse >/dev/null 2>&1 || pipewire-pulse &
	fi
fi

# Apply theme (generates ~/.config/atelier/current/ + wallpaper + gsettings)
if command -v atelier-theme >/dev/null 2>&1; then
	_cur="${XDG_CONFIG_HOME:-$HOME/.config}/atelier/current/theme.name"
	if [ -f "$_cur" ]; then
		atelier-theme set "$(cat "$_cur")" >/dev/null 2>&1 || true
	else
		atelier-theme set tokyo-night >/dev/null 2>&1 || true
	fi
	unset _cur
fi
if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/atelier/current/gtk-session.sh" ]; then
	# shellcheck source=/dev/null
	. "${XDG_CONFIG_HOME:-$HOME/.config}/atelier/current/gtk-session.sh"
fi

# GNOME/GTK settings (Nemo prefers gsettings). Theme script already set these;
# repeat as a fallback for first-login failures.
if command -v gsettings >/dev/null 2>&1; then
	gsettings set org.gnome.desktop.interface gtk-theme "${GTK_THEME:-Yaru-dark}" 2>/dev/null || true
	gsettings set org.gnome.desktop.interface icon-theme "${ATELIER_ICON_THEME:-Papirus-Dark}" 2>/dev/null || true
	gsettings set org.gnome.desktop.interface cursor-theme 'Yaru' 2>/dev/null || true
	gsettings set org.gnome.desktop.interface color-scheme "${ATELIER_COLOR_SCHEME:-prefer-dark}" 2>/dev/null || true
fi

# Starship: generated palette file when present
if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/atelier/current/starship.toml" ]; then
	export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/atelier/current/starship.toml"
else
	export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"
fi

# Root window color
if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/atelier/current/bspwm-colors.sh" ]; then
	# shellcheck source=/dev/null
	. "${XDG_CONFIG_HOME:-$HOME/.config}/atelier/current/bspwm-colors.sh"
fi
xsetroot -solid "${ATELIER_BG:-#1a1b26}"

# Multi-monitor layout (MVP: 1-2 displays) — before WM so bspwm sees geometry
# Skip: ATELIER_SKIP_MONITORS=1   Force prompt: ATELIER_MONITORS_FORCE=1
if [ -z "${ATELIER_SKIP_MONITORS:-}" ]; then
	if command -v atelier-monitors >/dev/null 2>&1; then
		atelier-monitors apply || true
	elif [ -x "$HOME/.config/atelier/atelier-monitors" ]; then
		"$HOME/.config/atelier/atelier-monitors" apply || true
	fi
fi

# Hand off to bspwm (must be last — replaces the shell)
exec bspwm

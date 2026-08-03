#!/bin/sh
# Atelier — default X session (~/.xinitrc)
# Starts a Tokyo Night themed bspwm desktop.

# Merge X resources
[ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"

# Qt: use qt5ct / qt6ct for theming
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_STYLE_OVERRIDE=

# GTK / icons (also set in settings.ini)
export GTK_THEME=Adwaita-dark
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=24

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

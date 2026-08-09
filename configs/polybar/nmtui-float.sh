#!/bin/sh
# Atelier — open nmtui in a floating, centered terminal (polybar click)
set -eu

if ! command -v nmtui >/dev/null 2>&1; then
	if command -v notify-send >/dev/null 2>&1; then
		notify-send "Atelier" "nmtui not found — install NetworkManager"
	else
		printf 'atelier: nmtui not found (install NetworkManager)\n' >&2
	fi
	exit 1
fi

# Prefer xterm: predictable WM_CLASS for a one-shot bspwm float rule
if command -v xterm >/dev/null 2>&1 && command -v bspc >/dev/null 2>&1; then
	bspc rule -a XTerm:atelier-nmtui -o state=floating center=on focus=on
	exec xterm -name atelier-nmtui -T "nmtui" -geometry 100x35 -e nmtui
fi

if command -v ghostty >/dev/null 2>&1; then
	if command -v bspc >/dev/null 2>&1; then
		# Ghostty GTK class varies by build; one-shot on common names
		bspc rule -a com.mitchellh.ghostty -o state=floating center=on focus=on 2>/dev/null || true
		bspc rule -a ghostty -o state=floating center=on focus=on 2>/dev/null || true
	fi
	if ghostty --help 2>&1 | grep -q -- '--title'; then
		exec ghostty --title=atelier-nmtui -e nmtui
	fi
	exec ghostty -e nmtui
fi

# Last resort: TUI on current tty (unlikely from polybar)
exec nmtui

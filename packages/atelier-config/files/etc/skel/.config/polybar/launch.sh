#!/bin/sh
# Atelier — launch polybar on each monitor
# Primary (xrandr) → atelier-primary (tray + full modules)
# Other outputs   → atelier-secondary
set -eu

# Stop existing bars (bounded wait so we never hang)
killall -q polybar 2>/dev/null || true
pkill -x polybar 2>/dev/null || true
_i=0
while pgrep -u "$(id -u)" -x polybar >/dev/null 2>&1; do
	_i=$((_i + 1))
	if [ "$_i" -gt 40 ]; then
		pkill -9 -x polybar 2>/dev/null || true
		break
	fi
	sleep 0.05
done

config="${XDG_CONFIG_HOME:-$HOME/.config}/polybar/config.ini"
[ -f "$config" ] || exit 0
command -v polybar >/dev/null 2>&1 || exit 0

start_bar() {
	# disown so bars survive if launcher is in a subshell
	MONITOR="$1" polybar -c "$config" "$2" >/dev/null 2>&1 &
	disown 2>/dev/null || true
}

# Optional override: space-separated monitors; first gets primary bar
if [ -n "${POLYBAR_MONITORS:-}" ]; then
	_first=1
	for m in $POLYBAR_MONITORS; do
		[ -n "$m" ] || continue
		if [ "$_first" -eq 1 ]; then
			start_bar "$m" atelier-primary
			_first=0
		else
			start_bar "$m" atelier-secondary
		fi
	done
	exit 0
fi

primary=""
if command -v xrandr >/dev/null 2>&1; then
	primary=$(xrandr --query 2>/dev/null | awk '/ connected primary/{ print $1; exit }')
fi

if ! polybar --list-monitors >/dev/null 2>&1; then
	polybar -c "$config" atelier-primary >/dev/null 2>&1 &
	disown 2>/dev/null || true
	exit 0
fi

# Capture list in this shell (no pipe subshell for the loop)
_mons=$(polybar --list-monitors | cut -d: -f1)
_first=1
for m in $_mons; do
	[ -n "$m" ] || continue
	if [ -n "$primary" ]; then
		if [ "$m" = "$primary" ]; then
			start_bar "$m" atelier-primary
		else
			start_bar "$m" atelier-secondary
		fi
	elif [ "$_first" -eq 1 ]; then
		start_bar "$m" atelier-primary
		_first=0
	else
		start_bar "$m" atelier-secondary
	fi
done

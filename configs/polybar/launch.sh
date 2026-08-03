#!/bin/sh
# Atelier — launch polybar for all monitors
# Kill existing bars, then start "atelier" on each connected display.

killall -q polybar
while pgrep -u "$(id -u)" -x polybar >/dev/null; do
	sleep 0.1
done

config="${XDG_CONFIG_HOME:-$HOME/.config}/polybar/config.ini"

if [ -n "$POLYBAR_MONITORS" ]; then
	# Optional override: space-separated monitor list
	for m in $POLYBAR_MONITORS; do
		MONITOR="$m" polybar -c "$config" atelier &
	done
elif command -v polybar >/dev/null 2>&1; then
	if polybar --list-monitors >/dev/null 2>&1; then
		polybar --list-monitors | cut -d: -f1 | while read -r m; do
			[ -n "$m" ] || continue
			MONITOR="$m" polybar -c "$config" atelier &
		done
	else
		polybar -c "$config" atelier &
	fi
fi

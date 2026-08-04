#!/bin/sh
# Atelier - reliable rofi launcher (PID file + XDG_RUNTIME_DIR)
# Installed as /usr/bin/atelier-rofi and ~/.config/rofi/atelier-rofi.sh
# Usage: atelier-rofi [drun|run|window|...]
set -eu

mode=${1:-drun}

# Ensure a writable runtime dir (startx often lacks /run/user/$UID)
if [ -z "${XDG_RUNTIME_DIR:-}" ] || [ ! -d "${XDG_RUNTIME_DIR}" ] || [ ! -w "${XDG_RUNTIME_DIR}" ]; then
	if [ -d "/run/user/$(id -u)" ] && [ -w "/run/user/$(id -u)" ]; then
		export XDG_RUNTIME_DIR="/run/user/$(id -u)"
	else
		export XDG_RUNTIME_DIR="${TMPDIR:-/tmp}/runtime-$(id -u)"
		mkdir -p "$XDG_RUNTIME_DIR"
		chmod 700 "$XDG_RUNTIME_DIR" 2>/dev/null || true
	fi
fi

# sxhkd may not pass DISPLAY; recover from X authority if possible
if [ -z "${DISPLAY:-}" ]; then
	if [ -n "${XAUTHORITY:-}" ] || [ -f "$HOME/.Xauthority" ]; then
		export DISPLAY="${DISPLAY:-:0}"
	fi
fi

pidfile="${XDG_RUNTIME_DIR}/rofi.pid"

# Toggle: if a live rofi holds the pid file, close it
if [ -f "$pidfile" ]; then
	oldpid=$(cat "$pidfile" 2>/dev/null || true)
	if [ -n "${oldpid:-}" ] && kill -0 "$oldpid" 2>/dev/null; then
		kill "$oldpid" 2>/dev/null || pkill -x rofi 2>/dev/null || true
		rm -f "$pidfile"
		exit 0
	fi
	rm -f "$pidfile"
fi

if pgrep -x rofi >/dev/null 2>&1; then
	pkill -x rofi 2>/dev/null || true
	rm -f "$pidfile"
	sleep 0.05
fi

# Use exec so rofi replaces this process (cleaner under sxhkd)
exec rofi -show "$mode"

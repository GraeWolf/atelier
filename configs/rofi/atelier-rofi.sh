#!/bin/sh
# Atelier — reliable rofi launcher (handles PID file + XDG_RUNTIME_DIR)
# Usage: atelier-rofi.sh [drun|run|window|...]
# Default mode: drun
set -eu

mode=${1:-drun}

# Ensure a writable runtime dir (startx sessions often lack /run/user/$UID)
if [ -z "${XDG_RUNTIME_DIR:-}" ] || [ ! -d "${XDG_RUNTIME_DIR}" ] || [ ! -w "${XDG_RUNTIME_DIR}" ]; then
	if [ -d "/run/user/$(id -u)" ] && [ -w "/run/user/$(id -u)" ]; then
		export XDG_RUNTIME_DIR="/run/user/$(id -u)"
	else
		export XDG_RUNTIME_DIR="${TMPDIR:-/tmp}/runtime-$(id -u)"
		mkdir -p "$XDG_RUNTIME_DIR"
		chmod 700 "$XDG_RUNTIME_DIR" 2>/dev/null || true
	fi
fi

pidfile="${XDG_RUNTIME_DIR}/rofi.pid"

# Drop stale PID file left by a crashed / killed instance
if [ -f "$pidfile" ]; then
	oldpid=$(cat "$pidfile" 2>/dev/null || true)
	if [ -n "${oldpid:-}" ] && kill -0 "$oldpid" 2>/dev/null; then
		# Already running: treat Super+d as toggle (close) so a second press works
		kill "$oldpid" 2>/dev/null || pkill -x rofi 2>/dev/null || true
		rm -f "$pidfile"
		exit 0
	fi
	rm -f "$pidfile"
fi

# Also clear orphaned rofi processes without a valid pid file
if pgrep -x rofi >/dev/null 2>&1; then
	pkill -x rofi 2>/dev/null || true
	rm -f "$pidfile"
	# brief pause so the pid file is released
	sleep 0.05
fi

exec rofi -show "$mode"

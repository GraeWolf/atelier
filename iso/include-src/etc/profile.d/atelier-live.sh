# Atelier live session helpers (live ISO only; installed via mklive -I include).
# Autostart X on tty1 when live.autologin is on the kernel command line.

atelier_live_should_startx() {
	[ -z "${DISPLAY:-}" ] || return 1
	[ "$(tty 2>/dev/null)" = "/dev/tty1" ] || return 1
	grep -qw 'live.autologin' /proc/cmdline 2>/dev/null || return 1
	command -v startx >/dev/null 2>&1 || return 1
	return 0
}

if atelier_live_should_startx; then
	# Avoid restart loops: only once per login shell
	if [ -z "${ATELIER_STARTED_X:-}" ]; then
		export ATELIER_STARTED_X=1
		exec startx
	fi
fi

# Atelier live session helpers (live ISO only; mklive -I include).
# Live boots to a TTY (no auto startx). Install from the shell with a TUI.

# Show once per interactive login on a real tty
case $- in
*i*) ;;
*) return 0 2>/dev/null || exit 0 ;;
esac

_tty=$(tty 2>/dev/null || true)
case "$_tty" in
/dev/tty* | /dev/console) ;;
*) unset _tty; return 0 2>/dev/null || true ;;
esac

if [ -z "${ATELIER_LIVE_HINT_SHOWN:-}" ]; then
	export ATELIER_LIVE_HINT_SHOWN=1
	printf '\n'
	printf '  Atelier Linux (live)\n'
	printf '  --------------------\n'
	printf '  Install (TUI):  sudo atelier-install\n'
	printf '  Install (GUI):  startx, then run atelier-install --gui\n'
	printf '                  or: sudo atelier-install --gui\n'
	printf '  Desktop only:   startx\n'
	printf '  Default login:  anon / voidlinux (void-mklive)\n'
	printf '\n'
fi
unset _tty

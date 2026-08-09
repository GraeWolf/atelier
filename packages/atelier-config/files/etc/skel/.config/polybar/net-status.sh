#!/bin/sh
# Atelier — polybar network up/down (default route present?)
# Output uses polybar foreground tags (Tokyo Night green / red).

if ip -4 route show default 2>/dev/null | grep -q . \
	|| ip -6 route show default 2>/dev/null | grep -q .; then
	printf '%%{F#9ece6a}up%%{F-}\n'
else
	printf '%%{F#f7768e}down%%{F-}\n'
fi

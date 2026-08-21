#!/bin/sh
# Atelier — polybar network: wifi vs ethernet icon + up/down
# Uses the interface of the default IPv4 (then IPv6) route.

# Nerd Font Symbols (polybar font-1 via %{T2}…%{T-})
ICON_WIFI='󰤨'   # nf-md-wifi
ICON_ETH='󰈀'    # nf-md-ethernet
ICON_DOWN='󰈂'   # nf-md-ethernet-off
COLOR_UP='#9ece6a'
COLOR_DOWN='#f7768e'
_sc="${XDG_CONFIG_HOME:-$HOME/.config}/atelier/current/shell-colors.sh"
if [ -f "$_sc" ]; then
	# shellcheck source=/dev/null
	. "$_sc"
fi
unset _sc

iface=""
# Prefer default IPv4 route device
iface=$(ip -4 route show default 2>/dev/null | awk '{
	for (i = 1; i <= NF; i++) if ($i == "dev") { print $(i + 1); exit }
}')
if [ -z "$iface" ]; then
	iface=$(ip -6 route show default 2>/dev/null | awk '{
		for (i = 1; i <= NF; i++) if ($i == "dev") { print $(i + 1); exit }
	}')
fi

is_wifi() {
	_if=$1
	[ -n "$_if" ] || return 1
	[ -d "/sys/class/net/${_if}/wireless" ] && return 0
	[ -e "/sys/class/net/${_if}/phy80211" ] && return 0
	# iwconfig / nl80211 style type
	if [ -r "/sys/class/net/${_if}/type" ]; then
		# ARPHRD_ETHER=1; wifi still often type 1 — prefer wireless/ dir
		:
	fi
	# Some drivers: uevent DEVTYPE=wlan
	if [ -r "/sys/class/net/${_if}/uevent" ] \
		&& grep -q 'DEVTYPE=wlan' "/sys/class/net/${_if}/uevent" 2>/dev/null; then
		return 0
	fi
	return 1
}

if [ -z "$iface" ]; then
	printf '%%{T2}%s%%{T-} %%{F%s}down%%{F-}\n' "$ICON_DOWN" "$COLOR_DOWN"
	exit 0
fi

# Carrier / operstate check (route can exist briefly while link is bad)
oper=$(cat "/sys/class/net/${iface}/operstate" 2>/dev/null || echo down)
if [ "$oper" != "up" ]; then
	if is_wifi "$iface"; then
		printf '%%{T2}%s%%{T-} %%{F%s}down%%{F-}\n' "$ICON_WIFI" "$COLOR_DOWN"
	else
		printf '%%{T2}%s%%{T-} %%{F%s}down%%{F-}\n' "$ICON_ETH" "$COLOR_DOWN"
	fi
	exit 0
fi

if is_wifi "$iface"; then
	printf '%%{T2}%s%%{T-} %%{F%s}up%%{F-}\n' "$ICON_WIFI" "$COLOR_UP"
else
	printf '%%{T2}%s%%{T-} %%{F%s}up%%{F-}\n' "$ICON_ETH" "$COLOR_UP"
fi

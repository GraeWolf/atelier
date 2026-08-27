#!/bin/sh
# Atelier — polybar battery: icon + percent, or empty (hidden) if none.
# First present Battery in /sys/class/power_supply (BAT0, BAT1, …).
# Desktops with only AC/USB supplies print nothing; polybar hides the module.

# Nerd Font Symbols (polybar font-1 via %{T2}…%{T-})
ICON_CHARGING='󰂄' # nf-md-battery-charging
ICON_FULL='󰁹'     # nf-md-battery
ICON_80='󰂁'       # nf-md-battery-80
ICON_60='󰁿'       # nf-md-battery-60
ICON_40='󰁽'       # nf-md-battery-40
ICON_20='󰁻'       # nf-md-battery-20
ICON_EMPTY='󰂎'    # nf-md-battery-outline

COLOR_UP='#9ece6a'
COLOR_DOWN='#f7768e'
_sc="${XDG_CONFIG_HOME:-$HOME/.config}/atelier/current/shell-colors.sh"
if [ -f "$_sc" ]; then
	# shellcheck source=/dev/null
	. "$_sc"
fi
unset _sc

bat=""
for d in /sys/class/power_supply/*; do
	[ -r "$d/type" ] || continue
	_type=$(cat "$d/type" 2>/dev/null) || continue
	[ "$_type" = "Battery" ] || continue
	if [ -r "$d/present" ]; then
		_present=$(cat "$d/present" 2>/dev/null) || _present=1
		[ "$_present" = "1" ] || continue
	fi
	bat=$d
	break
done
unset d _type _present

[ -n "$bat" ] || exit 0

capacity=$(cat "$bat/capacity" 2>/dev/null) || exit 0
case $capacity in
	''|*[!0-9]*) exit 0 ;;
esac

status=$(cat "$bat/status" 2>/dev/null || echo Unknown)

on_ac=0
case $status in
	Charging|Full|"Not charging") on_ac=1 ;;
esac

if [ "$on_ac" -eq 1 ]; then
	if [ "$capacity" -ge 99 ] || [ "$status" = "Full" ]; then
		icon=$ICON_FULL
	else
		icon=$ICON_CHARGING
	fi
elif [ "$capacity" -le 10 ]; then
	icon=$ICON_EMPTY
elif [ "$capacity" -le 25 ]; then
	icon=$ICON_20
elif [ "$capacity" -le 45 ]; then
	icon=$ICON_40
elif [ "$capacity" -le 65 ]; then
	icon=$ICON_60
elif [ "$capacity" -le 85 ]; then
	icon=$ICON_80
else
	icon=$ICON_FULL
fi

if [ "$on_ac" -eq 1 ]; then
	printf '%%{T2}%s%%{T-} %%{F%s}%s%%%%{F-}\n' "$icon" "$COLOR_UP" "$capacity"
elif [ "$capacity" -le 15 ]; then
	printf '%%{T2}%s%%{T-} %%{F%s}%s%%%%{F-}\n' "$icon" "$COLOR_DOWN" "$capacity"
else
	printf '%%{T2}%s%%{T-} %s%%\n' "$icon" "$capacity"
fi

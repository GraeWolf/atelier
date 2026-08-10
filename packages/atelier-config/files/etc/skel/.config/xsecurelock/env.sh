# Atelier — environment for xsecurelock / xss-lock
# Sourced from ~/.xinitrc and atelier-lock (not executed alone).

export XSECURELOCK_FONT="Fira Code:style=Regular:size=14"

# Password feedback: do NOT use time_hex (shows changing 0x… hex on each key).
# cursor = jumping cursor (no length leak, no hex). Alternatives: asterisks, hidden.
export XSECURELOCK_PASSWORD_PROMPT=cursor

export XSECURELOCK_SHOW_DATETIME=1
export XSECURELOCK_DATETIME_FORMAT="%Y-%m-%d %H:%M"
export XSECURELOCK_SHOW_HOSTNAME=0
export XSECURELOCK_SHOW_USERNAME=1
export XSECURELOCK_SHOW_KEYBOARD_LAYOUT=1

# Picom + xsecurelock: COMPOSITE_OBSCURER=1 causes a brief full-screen
# "INCOMPATIBLE COMPOSITOR, PLEASE FIX!" flash on unlock. Disable it.
export XSECURELOCK_COMPOSITE_OBSCURER=0

# Tokyo Night-ish auth dialog
export XSECURELOCK_AUTH_BACKGROUND_COLOR="#1a1b26"
export XSECURELOCK_AUTH_FOREGROUND_COLOR="#c0caf5"
export XSECURELOCK_BACKGROUND_COLOR="#16161e"

# Dimmer (xss-lock -n) timings when supported
export XSECURELOCK_DIM_TIME_MS="${XSECURELOCK_DIM_TIME_MS:-2000}"
export XSECURELOCK_WAIT_TIME_MS="${XSECURELOCK_WAIT_TIME_MS:-5000}"

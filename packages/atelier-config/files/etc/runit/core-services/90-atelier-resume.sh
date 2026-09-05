# Apply swapfile resume= to /sys/power so elogind CanHibernate is yes.
# Serialize device PM: mt7921e times out on async PCI restore after S4.
# Sourced from runit stage 1 (must not exit the boot).
[ -w /sys/power/pm_async ] && echo 0 >/sys/power/pm_async || true
[ -x /usr/bin/atelier-setup-swap ] || return 0
/usr/bin/atelier-setup-swap --apply-resume >/dev/null 2>&1 || true

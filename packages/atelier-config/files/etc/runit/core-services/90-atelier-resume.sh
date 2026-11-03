# Apply swapfile resume= to /sys/power so elogind CanHibernate is yes.
# Serialize device PM: mt7921e times out on async PCI restore after S4.
# Sourced from runit stage 1 (must not exit the boot).
[ -w /sys/power/pm_async ] && echo 0 >/sys/power/pm_async || true

# Void's nvidia.sh always runs "nvidia-sleep.sh hibernate", including for
# S3. atelier-nvidia is the one caller. A later nvidia package update
# restores the executable bit; clear it again every boot, before any sleep.
for _nvh in \
	/usr/libexec/elogind/system-sleep/nvidia.sh \
	/usr/lib/elogind/system-sleep/nvidia.sh \
	/usr/lib64/elogind/system-sleep/nvidia.sh
do
	if [ -x "$_nvh" ]; then
		chmod a-x "$_nvh" 2>/dev/null || true
	fi
done
unset _nvh

[ -x /usr/bin/atelier-setup-swap ] || return 0
/usr/bin/atelier-setup-swap --apply-resume >/dev/null 2>&1 || true

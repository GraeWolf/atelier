Atelier — proprietary NVIDIA notes
==================================

Packages
--------
- void-repo-nonfree  — enables Void nonfree mirror
- linux-headers      — required for nvidia-dkms
- nvidia             — proprietary drivers (nonfree; x86_64)
- atelier-nvidia     — blacklist nouveau, DRM modeset, suspend options, X11 snippet
- atelier-setup-nvidia — helper (ships in atelier-config, always on desktop)

Quick setup (installed system)
------------------------------
  sudo atelier-setup-nvidia
  sudo reboot

Xlibre
------
Xlibre's video ABI does not match nvidia_drv.so. Atelier's 20-nvidia.conf
uses the modesetting DDX against nvidia-drm. GL/Vulkan still come from
nvidia-libs. Hybrid (iGPU display + NVIDIA render): prime-run <command>

Do not set PrimaryGPU on hybrid laptops; the panel is on the iGPU.

Suspend / resume (discrete GPU, S3)
-----------------------------------
Black screen on wake is the modesetting framebuffer not being saved.

/etc/modprobe.d/atelier-nvidia.conf sets the same values modprobe
--show-depends would pass. The module is already loaded by then, at
about 2s, from udev, and that insert does not use the booted system's
modprobe.d. /proc/driver/nvidia/params stays at the 595.112.07 defaults
(Preserve=2, TemporaryFilePath empty, UseKernelSuspendNotifiers=0).

Those parameters are not in /sys/module/nvidia/parameters/ (permission 0).
/proc/driver/nvidia/params is the live copy.

The early insert does honor the kernel command line. atelier-nvidia-grub
adds this to GRUB_CMDLINE_LINUX_DEFAULT and runs grub-mkconfig:

  nvidia.NVreg_PreserveVideoMemoryAllocations=1
  nvidia.NVreg_TemporaryFilePath=/var/tmp
  nvidia.NVreg_UseKernelSuspendNotifiers=0

Reboot after that. Then PreserveVideoMemoryAllocations should be 1 and
TemporaryFilePath "/var/tmp".

/etc/elogind/system-sleep/atelier-nvidia (package atelier-config) is the
only caller of nvidia-sleep.sh. It passes suspend or hibernate, then
resume, including the VT switch. Void's
/usr/libexec/elogind/system-sleep/nvidia.sh always passes hibernate and
is chmod -x on install and on every boot.

S0ix (NVreg_EnableS0ixPowerManagement) stays off. It applies to s2idle,
not to mem_sleep "deep".

Reboot after installing so nvidia.ko reloads. Then: loginctl suspend.
If wake is still black: sudo atelier-nvidia-resume-log

Optional display server (PLAN default: Xlibre)
----------------------------------------------
  sudo atelier-setup-xlibre   # enables external repo and installs xlibre

Live ISO
--------
Default live images stay on X.Org + mesa for VM friendliness.
On NVIDIA hardware after install, run atelier-setup-nvidia (or choose NVIDIA
during atelier-install when offered).

Hardware testing
----------------
Validate on the real desktop (not WSL2):
  - lspci | grep -i nvidia
  - after reboot: lsmod | grep nvidia
  - nvidia-smi
  - startx → bspwm
  - hybrid offload: prime-run glxinfo

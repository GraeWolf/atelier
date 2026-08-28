Atelier — proprietary NVIDIA notes
==================================

Packages
--------
- void-repo-nonfree  — enables Void nonfree mirror
- linux-headers      — required for nvidia-dkms
- nvidia             — proprietary drivers (nonfree; x86_64)
- atelier-nvidia     — blacklist nouveau, DRM modeset, X11 snippet
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

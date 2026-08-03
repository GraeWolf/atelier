Atelier — proprietary NVIDIA notes
==================================

Packages
--------
- void-repo-nonfree  — enables Void nonfree mirror
- nvidia             — proprietary drivers (nonfree; x86_64)
- atelier-nvidia     — blacklist nouveau, DRM modeset, Xorg/Xlibre snippet

Quick setup (installed system)
------------------------------
  sudo atelier-setup-nvidia
  sudo reboot

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
  - startx → bspwm
  - glxinfo / nvidia-smi (if installed)

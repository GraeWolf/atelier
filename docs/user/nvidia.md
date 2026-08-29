# NVIDIA graphics on Atelier

Atelier targets a desktop PC with **proprietary NVIDIA** drivers.

`atelier-setup-nvidia` ships with the desktop (`atelier-config`). It is
available even if you skipped NVIDIA during install.

## After installation

If you enabled NVIDIA in the installer, reboot and start the graphical session (`startx` if needed).

If you skipped it, the installer failed that step, or you installed without the option:

```bash
sudo atelier-setup-nvidia
sudo reboot
```

Check the driver:

```bash
lspci | grep -i nvidia
lsmod | grep nvidia
nvidia-smi
```

Installer log on the new system: `/var/log/atelier-install.log`.

## Xlibre (optional but planned default)

```bash
sudo atelier-setup-xlibre
```

This enables a community repository and installs the Xlibre X server.

Xlibre does not use NVIDIA's proprietary `nvidia_drv.so` (ABI mismatch).
Atelier points `nvidia-drm` at the **modesetting** DDX. GL/Vulkan still
come from `nvidia-libs`. On hybrid laptops (AMD/Intel iGPU + NVIDIA),
the panel stays on the iGPU; use `prime-run <command>` for offload.

If the graphical session fails, switch to a TTY and reinstall X.Org:

```bash
sudo xbps-install -Sy xorg-server xorg-minimal
```

## Troubleshooting

| Symptom | Try |
|---------|-----|
| Black screen on boot | TTY login (`Ctrl+Alt+F2`), check `dmesg \| grep -i nvidia`. Installer log: `/var/log/atelier-install.log` |
| `atelier-setup-nvidia` not found | Update `atelier-config` from the personal repo (helper lives there, not in `atelier-nvidia`) |
| nouveau still loading | Confirm `/etc/modprobe.d/atelier-blacklist-nouveau.conf` exists; rebuild initramfs / reboot |
| DKMS errors / nvidia-smi cannot talk to the driver | `sudo xbps-install -Sy linux-headers` matching `uname -r`; reinstall `nvidia-dkms`; reboot into that kernel |
| Hybrid laptop, black screen after NVIDIA | Do not set `PrimaryGPU`. Display should stay on the iGPU; offload with `prime-run` |
| Hibernate on hybrid NVIDIA does not resume | Void’s nvidia package already installs elogind sleep hooks. Swap/resume is separate (`atelier-setup-swap`). Firmware/driver resume can still fail; suspend-to-RAM is the fallback |
| VM has no NVIDIA | Do not install proprietary drivers in the VM; use the default mesa live image |

More detail for builders: `docs/build/nvidia.md`.

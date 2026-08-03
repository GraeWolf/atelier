# NVIDIA graphics on Atelier

Atelier targets a desktop PC with **proprietary NVIDIA** drivers.

## After installation

If you enabled NVIDIA in the installer, reboot and start the graphical session (`startx` if needed).

If you skipped it (or installed without the option):

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

## Xlibre (optional but planned default)

```bash
sudo atelier-setup-xlibre
```

This enables a community repository and installs the Xlibre X server.  
If the graphical session fails, switch to a TTY and reinstall X.Org:

```bash
sudo xbps-install -Sy xorg-server xorg-minimal
```

## Troubleshooting

| Symptom | Try |
|---------|-----|
| Black screen on boot | TTY login (`Ctrl+Alt+F2`), check `dmesg \| grep -i nvidia`, `journalctl` N/A on runit — use logs in `/var/log` |
| nouveau still loading | Confirm `/etc/modprobe.d/atelier-blacklist-nouveau.conf` exists; rebuild initramfs / reboot |
| DKMS errors | `sudo xbps-install -Sy linux-headers` matching your kernel; reinstall `nvidia-dkms` |
| VM has no NVIDIA | Do not install proprietary drivers in the VM; use the default mesa live image |

More detail for builders: `docs/build/nvidia.md`.

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

On the RTX 4060 Ti desktop the installer preset also installs Steam. That step adds `nvidia-libs-32bit` so 32-bit games can use the proprietary driver. If the result screen says those libraries were skipped:

```bash
sudo xbps-install -S nvidia-libs-32bit
```

Check the driver:

```bash
lspci | grep -i nvidia
lsmod | grep nvidia
nvidia-smi
```

Installer log on the new system: `/var/log/atelier-install.log`.

## XLibre

The installer always installs XLibre (no X.Org fallback). On a system that
was installed before that, or to reinstall the server:

```bash
sudo atelier-setup-xlibre
```

This enables a community repository and installs the XLibre X server.

Xlibre does not use NVIDIA's proprietary `nvidia_drv.so` (ABI mismatch).
Atelier points `nvidia-drm` at the **modesetting** DDX. GL/Vulkan still
come from `nvidia-libs`. On hybrid laptops (AMD/Intel iGPU + NVIDIA),
the panel stays on the iGPU; use `prime-run <command>` for offload.

If the graphical session fails, switch to a TTY and reinstall X.Org:

```bash
sudo xbps-install -Sy xorg-server xorg-minimal
```

## Black screen after suspend

Waking from idle suspend or `loginctl suspend` used to leave the monitor black until a reboot. The desktop is on S3 (`deep` in `/sys/power/mem_sleep`). Two things were wrong:

- The driver default `PreserveVideoMemoryAllocations: 2` does not save the modesetting framebuffer (XLibre does not use `nvidia_drv.so`).
- Void’s elogind hook always tells the GPU to **hibernate**, including for suspend-to-RAM, and Atelier’s own hook did not send `suspend` / `resume`.

The packaged fix has two parts. The modprobe file is what a later `modprobe` would pass (`modprobe --show-depends nvidia` prints it). The module that is already running was inserted at about 2 seconds by udev, before that config is the one in effect, so `/proc/driver/nvidia/params` stays at the 595.112.07 defaults: Preserve `2`, empty TemporaryFilePath, UseKernelSuspendNotifiers `0`. Those names are absent under `/sys/module/nvidia/parameters/` because the driver registers them with permission 0. `/proc/driver/nvidia/params` is the live value.

The early insert does honor `nvidia.NVreg_*` on the kernel command line. After the package update (or the commands below), **reboot once**. The driver keeps the old parameters until then.

These two packages are built from the Atelier tree (`./scripts/build-repo.sh` → `repo/out/`). They are not in the public GraeWolf void-repo that supplies `brave-origin`. The desktop does not need a git checkout.

On a machine that already has `0.2.0_3`, you can add the command line without waiting for another package. Back up GRUB, append the three tokens if they are not already there, regenerate the menu, and reboot:

```bash
sudo cp -a /etc/default/grub /etc/default/grub.bak
grep -q 'NVreg_PreserveVideoMemoryAllocations=1' /etc/default/grub || \
  sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/s/"[[:space:]]*$/ nvidia.NVreg_PreserveVideoMemoryAllocations=1 nvidia.NVreg_TemporaryFilePath=\/var\/tmp nvidia.NVreg_UseKernelSuspendNotifiers=0"/' /etc/default/grub
grep '^GRUB_CMDLINE_LINUX_DEFAULT=' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo reboot
```

After reboot the command line must contain the tokens, and the proc file must change:

```bash
tr ' ' '\n' </proc/cmdline | grep NVreg
grep -E 'PreserveVideoMemoryAllocations|TemporaryFilePath|UseKernelSuspendNotifiers' /proc/driver/nvidia/params
```

Expected after that reboot: `PreserveVideoMemoryAllocations: 1`, `TemporaryFilePath: "/var/tmp"`, `UseKernelSuspendNotifiers: 0`. A test of `0.2.0_3` already resumed to the lock screen and the desktop while Preserve was still `2`, so the GRUB tokens are the documented NVIDIA setting and may not be required on this 4060 Ti.

`loginctl suspend` should reach the sleep hooks in a few seconds. xss-lock holds a sleep/delay inhibitor named `Lock screen first` until the locker closes `XSS_SLEEP_LOCK_FD`. xsecurelock only closed that fd after its saver window mapped, so elogind waited. `atelier-config` 0.3.13_5 closes the fd once xsecurelock is running, and sets `InhibitDelayMaxSec=10` so a stuck fd cannot hold sleep for minutes. elogind reads the cap when it starts (`sudo sv restart elogind`, or reboot). NetworkManager and RealtimeKit also take short sleep/delay locks. Brave's lock is shutdown/delay, not sleep. Idle or manual lock still waits 2 minutes before it suspends on its own; that timer is not used when suspend was already requested.

The GRUB edit is what `atelier-nvidia` 0.2.0_4 runs (`atelier-nvidia-grub`). Copy a rebuilt `repo/out` to the desktop (these packages are not in the public GraeWolf repo). `atelier-config` 0.3.13_5 is this round's sleep-lock fix.

```bash
sudo xbps-install --repository=/mnt/atelier-repo -S atelier-nvidia atelier-config
sudo reboot
```

If xbps asks whether to replace `/etc/modprobe.d/atelier-nvidia.conf` or `/etc/elogind/system-sleep/atelier-nvidia`, take the new package file. Check the versions with `xbps-query atelier-nvidia atelier-config`.

`0.3.13_5` still left about a minute between `loginctl suspend` and the first sleep hook, which is longer than `InhibitDelayMaxSec` (10s). The NVIDIA handshake itself was one second, so that gap is not the VRAM save or `chvt`. `atelier-config` 0.3.13_6 writes the kernel `PM:` / `Freezing` lines (with `dmesg -T`) into the post snapshot, and `atelier-pm-watch` uses `busctl` so it runs without `dbus-monitor`.

Time one cycle. The first timestamp is when you press enter. Compare it with `PrepareForSleep` (elogind accepted the call) and with `atelier-nvidia pre` (hooks started). The piece before `PrepareForSleep` is outside the inhibitor cap (often polkit). The piece from `PrepareForSleep` to `pre` is the delay locks, and should be under 10s. The piece from `pre` to `PM: suspend entry` is the hooks after `atelier-pm-log` (including `atelier-wifi`) and the kernel.

```bash
date -u +%Y-%m-%dT%H:%M:%SZ
loginctl suspend
```

After wake:

```bash
sudo dmesg -T | grep -E 'PM:|Freezing|Filesystems sync|nvidia|NVRM|timeout|blocked' | tail -60
sudo awk '/atelier-pm-watch: PrepareForSleep|atelier-nvidia: pre: start|======== /{print}' /var/log/atelier-pm.log | tail -40
tail -40 "${XDG_RUNTIME_DIR:-/tmp}/atelier-prepare-sleep.log"
```

While a suspend is still waiting (from another TTY if the session is frozen on the lock screen):

```bash
busctl call org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager ListInhibitors
busctl get-property org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager InhibitDelayMaxUSec
```

`ListInhibitors` is `a(ssssuu)`: what, who, why, mode, uid, pid. After 0.3.13_5, `InhibitDelayMaxUSec` should be `10000000` (10s) once elogind has been restarted.

If the screen is still black after wake, switch to a text console with `Ctrl+Alt+F2`. If that works, the system is up and the display mode was not restored. Either way, reboot if you cannot get a shell, then run:

```bash
sudo atelier-nvidia-resume-log
```

Send that output back. It includes `/var/log/atelier-pm.log` (written before sleep and again after wake when the hooks run) and, when `socklog` is installed, the kernel log under `/var/log/socklog/kernel/`. `dmesg` after a reboot is only the new boot.

`/var/tmp` must have room for the GPU memory (8 GiB or 16 GiB on a 4060 Ti, plus a little margin). `df -h /var/tmp` shows that.

This was not tested on real hardware here. Suspend needs the desktop.

## Troubleshooting

| Symptom | Try |
|---------|-----|
| Black screen on boot | TTY login (`Ctrl+Alt+F2`), check `dmesg \| grep -i nvidia`. Installer log: `/var/log/atelier-install.log` |
| `atelier-setup-nvidia` not found | Update `atelier-config` from the personal repo (helper lives there, not in `atelier-nvidia`) |
| nouveau still loading | Confirm `/etc/modprobe.d/atelier-blacklist-nouveau.conf` exists; rebuild initramfs / reboot |
| DKMS errors / nvidia-smi cannot talk to the driver | `sudo xbps-install -Sy linux-headers` matching `uname -r`; reinstall `nvidia-dkms`; reboot into that kernel |
| Hybrid laptop, black screen after NVIDIA | Do not set `PrimaryGPU`. Display should stay on the iGPU; offload with `prime-run` |
| Black screen after suspend, until reboot | See [Black screen after suspend](#black-screen-after-suspend). Reboot after the package update, then `loginctl suspend`. Still broken: `sudo atelier-nvidia-resume-log` |
| Hibernate on hybrid NVIDIA does not resume | The Atelier hook unloads the dGPU when `amdgpu` is also loaded, and disables Void’s hook (that script always calls `nvidia-sleep.sh hibernate`). Swap/resume is separate (`atelier-setup-swap`). Firmware can still fail; suspend-to-RAM is the fallback |
| Resume works ~30–60s then the machine reboots | Session is on the iGPU; the dGPU can still time out. Read `/var/log/atelier-pm.log` (see [desktop.md](desktop.md#hibernate-resume-then-reboot)) |
| VM has no NVIDIA | Do not install proprietary drivers in the VM; use the default mesa live image |

More detail for builders: `docs/build/nvidia.md`.

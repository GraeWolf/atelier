# NVIDIA proprietary + Xlibre (Phase 1 Step 6)

## Goals

- Installed desktop works with **proprietary NVIDIA** drivers (Void nonfree)
- **Xlibre** available via external xlibre-void repository (PLAN display server)
- Clear path from live ISO → installed system on the primary NVIDIA desktop
- Default live ISO remains VM-friendly (mesa / X.Org), not forced onto nvidia.ko

## Packages (personal repo)

| Package | Role |
|---------|------|
| `atelier-config` | Ships `atelier-setup-nvidia` (always on the desktop) |
| `atelier-nvidia` | Configs + depends on `void-repo-nonfree` + `nvidia` |
| `atelier-xlibre-repo` | Public key + xbps.d for xlibre-void; `atelier-setup-xlibre` |

### Config files (`atelier-nvidia`)

| Path | Purpose |
|------|---------|
| `/etc/modprobe.d/atelier-blacklist-nouveau.conf` | Blacklist nouveau |
| `/etc/modprobe.d/atelier-nvidia.conf` | `nvidia-drm modeset=1 fbdev=1`; `NVreg_PreserveVideoMemoryAllocations=1`; `NVreg_TemporaryFilePath=/var/tmp`; `NVreg_UseKernelSuspendNotifiers=0` |
| `/etc/modules-load.d/atelier-nvidia.conf` | Load nvidia modules at boot |
| `/etc/X11/xorg.conf.d/20-nvidia.conf` | OutputClass: **modesetting** DDX (not `nvidia_drv.so`) |

`atelier-config` ships the elogind side: `/etc/elogind/system-sleep/atelier-nvidia`, `/etc/elogind/sleep.conf.d/atelier-nvidia.conf` (`HandleNvidiaSleep=no`), and `/usr/bin/atelier-nvidia-resume-log`. The boot service `90-atelier-resume.sh` clears the executable bit on Void’s hook every boot.

Xlibre video ABI 28 does not match Void's `nvidia_drv.so` (ABI 25). Hybrid
laptops must not set `PrimaryGPU`; the panel is on the iGPU. Offload with
`prime-run`.

### Setup helpers

```bash
sudo atelier-setup-nvidia   # enable nonfree, install linux-headers + nvidia + atelier-nvidia
sudo atelier-setup-xlibre   # enable xlibre-void, install xlibre
```

`atelier-setup-nvidia` is in `atelier-config`, not `atelier-nvidia`, so the
documented recovery path exists when NVIDIA was skipped at install.

## Void sources

| Component | Source |
|-----------|--------|
| `nvidia` (and subpackages) | Void **nonfree** (`void-repo-nonfree`) |
| `xlibre` | External: [xlibre-void](https://github.com/xlibre-void/xlibre) |
| `xorg-minimal` | Official Void (live ISO only; the installer does not fall back to X.Org) |

## Installer behavior

`atelier-install` asks whether to install proprietary NVIDIA (offered when
`lspci` or sysfs sees an NVIDIA GPU). XLibre is always installed; there is
no X.Org fallback.

When NVIDIA is selected, the target gets a **separate** xbps transaction
for `linux-headers`, `nvidia`, and `atelier-nvidia` (if in personal repo).
Failure of that transaction does not roll back the desktop. The result
screen says so and points at `sudo atelier-setup-nvidia`. A failing
`xbps-reconfigure -a` is also shown there (it used to be hidden with
`|| true`). The log is `/var/log/atelier-install.log`.

When the preset `GAMING` is yes and NVIDIA packages were installed, a
later transaction installs `nvidia-libs-32bit` from multilib/nonfree
(same driver version as `nvidia`). If the NVIDIA transaction failed,
that 32-bit package is skipped and the result screen says Steam
installed without it.

## Live ISO strategy

| Image | Graphics |
|-------|----------|
| Default (`live.txt`) | `xorg-minimal` + mesa (VM / generic) |
| Optional (`nvidia.txt`) | Documented list for specialized builds |

Shipping full proprietary NVIDIA on every live ISO is avoided: large download, poor VM behavior, and DKMS needs the running kernel.

On NVIDIA hardware after a normal install:

```bash
sudo atelier-setup-nvidia
sudo reboot
# optional PLAN display server:
sudo atelier-setup-xlibre
```

Or select NVIDIA in the dialog installer. XLibre is installed either way.

## Building personal packages

```bash
./scripts/build-repo.sh
xbps-query --repository=$PWD/repo/out -Rs 'atelier-nvidia|atelier-xlibre'
```

## Hardware test checklist (desktop machine)

- [ ] Install from live ISO (or run setup scripts on existing install)
- [ ] `lspci -nn \| grep -i nvidia`
- [ ] After reboot: `lsmod \| grep nvidia`
- [ ] `cat /proc/driver/nvidia/version` or `nvidia-smi`
- [ ] `startx` → bspwm / polybar / ghostty
- [ ] Optional: Xlibre session after `atelier-setup-xlibre`
- [ ] Picom runs without hard lockup (blur already off in Atelier config)
- [ ] Note kernel version + nvidia package version in a test log
- [ ] After reboot: `grep PreserveVideoMemoryAllocations /proc/driver/nvidia/params` is `1`
- [ ] `loginctl suspend`, wake, session returns (real hardware only)

## Suspend and resume (discrete RTX, S3)

Symptom on the installed desktop: idle suspend or `loginctl suspend` wakes to a black screen. Only a reboot brings the display back. Reported runtime state:

- `PreserveVideoMemoryAllocations: 2` in `/proc/driver/nvidia/params`
- `/etc/elogind/system-sleep/` contains `atelier-nvidia`, `atelier-pm-log`, `atelier-wifi`
- `/sys/power/mem_sleep` is `s2idle [deep]` (S3, not s2idle)

### Cause

`2` is the driver default, “auto”. Full video-memory save happens only when kernel suspend notifiers are in use. The modesetting scanout buffer (XLibre’s modesetting DDX on `nvidia-drm`, not `nvidia_drv.so`) is not in the smaller set. Wake has nothing to put back on the monitor.

Void’s `nvidia` package (595.x, open kernel modules plus proprietary userspace) installs `/usr/bin/nvidia-sleep.sh` and `/usr/libexec/elogind/system-sleep/nvidia.sh`. The elogind script **ignores `$2` and always runs `nvidia-sleep.sh hibernate`**, then sleeps 5 seconds. That is the wrong verb for `deep` suspend and for the suspend half of suspend-then-hibernate (the idle lock path). elogind’s arguments are `$1=pre|post` and `$2=suspend|hibernate|hybrid-sleep|suspend-then-hibernate`. The specific phase is `$SYSTEMD_SLEEP_ACTION` (`suspend` then `hibernate` across suspend-then-hibernate).

Atelier’s hook used to call `nvidia-sleep.sh` as well. Two callers deadlock on an rw-semaphore in `nvidia.ko`. The hook was changed to unload `nvidia` only when `amdgpu` is also loaded, and to do nothing on a discrete GPU. Nothing on the desktop wrote `suspend` before S3 or `resume` after it, and nothing pinned `NVreg_PreserveVideoMemoryAllocations=1`.

`NVreg_EnableS0ixPowerManagement` is not part of this failure. S0ix is for `s2idle` when the platform and the GPU both support video-memory self refresh. This machine’s active mem_sleep is `deep`. The option stays at the driver default `0`.

`nvidia-drm` `fbdev=1` is the driver default since 545 and is now set explicitly so the VT switch in `nvidia-sleep.sh` has a framebuffer console to return to.

### What the packages do

`atelier-nvidia` modprobe file:

```
options nvidia-drm modeset=1 fbdev=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp NVreg_UseKernelSuspendNotifiers=0
```

`=1` is what the 595 README requires for a full save. The procfs interface is required with that setting. `UseKernelSuspendNotifiers=0` keeps `/proc/driver/nvidia/suspend` present. On the open modules in the 595.112.07 sources that value is already the default (later branches flipped the default to 1). Seeing `0` in `/proc/driver/nvidia/params` does not mean the option was applied. `/var/tmp` is on the root filesystem; `/tmp` is often a tmpfs too small for 8–16 GiB of VRAM.

`modprobe --show-depends nvidia` prints an `insmod` line that includes those three `NVreg_*` arguments. That is the command a new modprobe would run. The desktop inserts `nvidia.ko` at about 2 seconds (nvidia-drm fbcon follows immediately) via udev, while kmod is still using the initramfs modprobe configuration. The `.ko` is not copied into the initramfs (`lsinitrd` shows no nvidia file); it is loaded from the mounted root. The module then stays resident, so the real `/etc/modprobe.d` never gets a turn. `/proc/driver/nvidia/params` is those parameters (they are registered with permission 0, so `/sys/module/nvidia/parameters/NVreg_*` does not exist). After a reboot onto `0.2.0_3` the proc file was still the 595.112.07 defaults: Preserve `2`, TemporaryFilePath `""`, notifiers `0`.

kmod does read `nvidia.NVreg_*=` from `/proc/cmdline` during that early insert. `atelier-nvidia-grub` (package install script) appends the three tokens to `GRUB_CMDLINE_LINUX_DEFAULT` and runs `grub-mkconfig`. `/etc/dracut.conf.d/atelier-nvidia.conf` also copies the modprobe file into the initramfs. nvidia.ko is still not forced into the image.

`atelier-config`’s hook, when it is the only caller:

1. `pre` + suspend (or the suspend phase of suspend-then-hibernate) → `nvidia-sleep.sh suspend`
2. `pre` + hibernate → `nvidia-sleep.sh hibernate`
3. `post` → `nvidia-sleep.sh resume`

`nvidia-sleep.sh` records the VT, `chvt 63`, writes the verb to `/proc/driver/nvidia/suspend`, and on resume writes `resume` and switches back. If `/usr/bin/nvidia-sleep.sh` is absent the hook does those steps itself.

Void’s hook is `chmod a-x` from the package install scripts and from `90-atelier-resume.sh` on every boot (a later `nvidia` package update puts the executable bit back). `HandleNvidiaSleep=no` stops elogind doing a third handshake. Hybrid (`amdgpu` and `nvidia` both loaded) still unloads the dGPU and does not call `nvidia-sleep.sh` unless unload fails.

The hook always exits 0. It logs to `/var/log/atelier-pm.log`.

### Initramfs

Options are read when `nvidia.ko` is loaded. A reboot is required. If the modules are already in the initramfs, that image has its own copy of `modprobe.d`, so the `atelier-nvidia` install script runs `dracut --force --regenerate-all` after the new file is unpacked. The script does not add `force_drivers`: loading nvidia from the initramfs makes 595 fail hibernation restore (`PM_RESTORE_PREPARE` / missing procfs in the fresh initramfs). Dracut still copies `/etc/modprobe.d` when the module is included for another reason.

Package revisions: `atelier-nvidia` 0.2.0_4, `atelier-config` 0.3.13_4. See [user nvidia.md](../user/nvidia.md#black-screen-after-suspend) for the desktop commands, including the GRUB edit that applies before the next package build is installed.

### Logs after a failed resume

`atelier-pm-log` appends a pre snapshot (including a dmesg tail and the NVIDIA parameters) before the machine sleeps, and a post snapshot plus `still-alive` lines if userspace runs after wake. `atelier-nvidia` appends the verb, `/var/tmp` free space, and the `nvidia-sleep.sh` exit code to the same file.

```bash
sudo atelier-nvidia-resume-log
```

That prints package versions, `/proc/driver/nvidia/params`, whether `/proc/driver/nvidia/suspend` exists, whether Void’s hook is still executable, `dmesg` lines for this boot, the tail of `/var/log/atelier-pm.log`, and `/var/log/socklog/kernel/current` when socklog/svlogd is installed.

Atelier does not install a persistent syslog. After a power-cycle, `dmesg` is only the new boot. The pre block in `/var/log/atelier-pm.log` is the record from before sleep. Kernel messages from the dead cycle survive only if socklog was already writing `/var/log/socklog/kernel/`.

A `0.2.0_3` cycle on the desktop (Preserve still `2`) did resume to the lock screen and the desktop after `loginctl suspend`. The GRUB tokens remain the documented way to pin the parameters; they may not be required for resume on this GPU. The multi-minute pause before the hooks was xss-lock's sleep/delay inhibitor, not the driver. See `atelier-lock` and `InhibitDelayMaxSec=10`.

Real suspend was not run in the build environment. Check scripts with `bash -n` and `shellcheck -s sh`.

## Risks / notes

- `nvidia` is **x86_64-only** on Void
- DKMS rebuilds against the installed kernel (`linux`); headers must match `uname -r`
- Xlibre is third-party; keep TTY recovery + ability to reinstall `xorg-server`
- Xlibre: use modesetting DDX + nvidia kernel module, not proprietary `nvidia_drv.so`
- Suspend: `NVreg_PreserveVideoMemoryAllocations=1` needs the procfs hook and `UseKernelSuspendNotifiers=0`. Do not call `nvidia-sleep.sh` from a second script. Do not force nvidia into the initramfs.
- Never commit private signing keys (Xlibre **public** key is shipped on purpose)

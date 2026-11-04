# Atelier Linux — installed system

You are helping with a machine that runs Atelier, a personal Void Linux system. This file is the diagnostic context (`/usr/share/atelier/AGENTS.md`). Read it before changing boot, graphics, suspend, or packages. Ask before those changes. The person will describe the problem.

Repository: https://github.com/GraeWolf/atelier

No username, hostname, or other personal detail belongs in that repository.

## Layout

- Base: Void Linux. Init: runit. No systemd units.
- Session: `startx` and bspwm. There is no display manager.
- Display server: XLibre only. The installer stops if XLibre does not install. There is no X.Org fallback.
- Hardware this desktop targets: NVIDIA RTX 4060 Ti, proprietary driver.
- Package manager: xbps. Personal packages are built from the git tree with `./scripts/build-repo.sh` and installed with `sudo xbps-install --repository="$PWD/repo/out" -S <pkg>`.
- The installer enables the runit services NetworkManager, dbus, and elogind.

## Power and NVIDIA

elogind hooks live in `/etc/elogind/system-sleep/`. They must exit 0. elogind will not enter sleep until they return, and a line on stdout that starts with `ERROR`, `FAILED`, `CRITICAL`, or `CANCELLED` can cancel sleep. Log to `/var/log/atelier-pm.log`, not stdout.

- `atelier-nvidia` is the only caller of `nvidia-sleep.sh`. `/etc/elogind/sleep.conf.d/atelier-nvidia.conf` sets `HandleNvidiaSleep=no` so elogind does not suspend the GPU a second time (that deadlocks on a driver semaphore). Void's own `nvidia.sh` always runs `nvidia-sleep.sh hibernate`, including for S3; `/etc/runit/core-services/90-atelier-resume.sh` clears its executable bit on every boot.
- `atelier-pm-log` appends a pre/post snapshot to `/var/log/atelier-pm.log`. Atelier has no persistent syslog.
- `atelier-wifi` unloads a bound MediaTek mt7921/mt7925 around sleep. Hook commands are time-limited (`sync` 5s, `modprobe -r` 3s).
- `/etc/elogind/logind.conf.d/atelier-suspend.conf` sets `InhibitDelayMaxSec=10`.

The proprietary module is inserted by udev early in boot, before `/etc/modprobe.d` is the config in effect. The options that actually apply are on the GRUB kernel command line:

```
nvidia.NVreg_PreserveVideoMemoryAllocations=1
nvidia.NVreg_TemporaryFilePath=/var/tmp
nvidia.NVreg_UseKernelSuspendNotifiers=0
```

`/proc/driver/nvidia/params` shows the live values. Do not read `/proc/driver/nvidia/*` from a sleep hook after the GPU has been told to suspend. That read can block the sleep path. The pre hook of `atelier-pm-log` runs after `atelier-nvidia` in lexical order, so treat a hang there as a possible procfs read against an already-suspended GPU.

Installer log on the installed system: `/var/log/atelier-install.log`.

## Grok Build

The CLI is per user, in `~/.grok/bin/grok`, when the installer preset `AI=yes` succeeded. First launch signs in with a browser, or with `XAI_API_KEY` in the environment. Neither a key nor a login is stored in the Atelier repository. Ask AI (Super+Shift+A, or the system menu) starts Grok in a directory whose only project rule is this file.

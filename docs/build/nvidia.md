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
| `/etc/modprobe.d/atelier-nvidia.conf` | `nvidia-drm modeset=1` |
| `/etc/modules-load.d/atelier-nvidia.conf` | Load nvidia modules at boot |
| `/etc/X11/xorg.conf.d/20-nvidia.conf` | OutputClass: **modesetting** DDX (not `nvidia_drv.so`) |

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

Or select NVIDIA in the graphical installer. XLibre is installed either way.

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

## Risks / notes

- `nvidia` is **x86_64-only** on Void
- DKMS rebuilds against the installed kernel (`linux`); headers must match `uname -r`
- Xlibre is third-party; keep TTY recovery + ability to reinstall `xorg-server`
- Xlibre: use modesetting DDX + nvidia kernel module, not proprietary `nvidia_drv.so`
- Never commit private signing keys (Xlibre **public** key is shipped on purpose)

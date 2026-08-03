# NVIDIA proprietary + Xlibre (Phase 1 Step 6)

## Goals

- Installed desktop works with **proprietary NVIDIA** drivers (Void nonfree)
- **Xlibre** available via external xlibre-void repository (PLAN display server)
- Clear path from live ISO → installed system on the primary NVIDIA desktop
- Default live ISO remains VM-friendly (mesa / X.Org), not forced onto nvidia.ko

## Packages (personal repo)

| Package | Role |
|---------|------|
| `atelier-nvidia` | Configs + depends on `void-repo-nonfree` + `nvidia` |
| `atelier-xlibre-repo` | Public key + xbps.d for xlibre-void; `atelier-setup-xlibre` |

### Config files (`atelier-nvidia`)

| Path | Purpose |
|------|---------|
| `/etc/modprobe.d/atelier-blacklist-nouveau.conf` | Blacklist nouveau |
| `/etc/modprobe.d/atelier-nvidia.conf` | `nvidia-drm modeset=1` |
| `/etc/modules-load.d/atelier-nvidia.conf` | Load nvidia modules at boot |
| `/etc/X11/xorg.conf.d/20-nvidia.conf` | OutputClass for nvidia |

### Setup helpers

```bash
sudo atelier-setup-nvidia   # enable nonfree, install nvidia + atelier-nvidia
sudo atelier-setup-xlibre   # enable xlibre-void, install xlibre
```

## Void sources

| Component | Source |
|-----------|--------|
| `nvidia` (and subpackages) | Void **nonfree** (`void-repo-nonfree`) |
| `xlibre` | External: [xlibre-void](https://github.com/xlibre-void/xlibre) |
| `xorg-minimal` | Official Void (default live / fallback) |

## Installer behavior

`atelier-install` asks:

1. Whether to install proprietary NVIDIA (default yes if `lspci` sees NVIDIA)
2. Whether to install Xlibre from the external repo

When NVIDIA is selected, the target gets nonfree enabled and packages  
`void-repo-nonfree`, `nvidia`, and `atelier-nvidia` (if in personal repo).

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

Or select NVIDIA/Xlibre in the graphical installer.

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
- DKMS rebuilds against the installed kernel (`linux`)
- Xlibre is third-party; keep TTY recovery + ability to reinstall `xorg-server`
- Never commit private signing keys (Xlibre **public** key is shipped on purpose)

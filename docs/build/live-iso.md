# Live ISO build (void-mklive)

How to build the Atelier live ISO (Phase 1 Step 4).

## Goals (this step)

- Bootable live ISO via **void-mklive**
- **Personal repository** integrated (build-time install + on-medium repo)
- Themed **bspwm** desktop from `atelier-desktop` / `atelier-config`
- Temporary **void-installer** (custom GUI installer is Step 5)
- **X.Org** for first image / VM testing (**Xlibre** comes with later NVIDIA work)

## Requirements

| Requirement | Notes |
|-------------|--------|
| Void Linux host | Official mklive support target |
| **Root** | `void-mklive` must run as root |
| Network | Fetch packages from Void mirrors |
| Disk | Several GB for xbps cache + squashfs + ISO |
| Tools | `git`, `xbps-*`, `xorriso`, `squashfs-tools`, `xz` |

Install build tools if needed:

```bash
sudo xbps-install -S git xorriso squashfs-tools xz mtools dosfstools
```

WSL2: packaging works; full GUI/NVIDIA validation may need a VM or the second (desktop) machine.

## Quick build

From the monorepo root:

```bash
# 1) Validate prep without root (recommended first)
./scripts/build-iso.sh --check

# 2) Full ISO (root required)
sudo ./scripts/build-iso.sh
```

Output (default):

```text
iso/output/atelier-YYYYMMDD-x86_64.iso
```

Do **not** burn/write the ISO to disks without explicit care; this project’s agent rules forbid unsolicited media writes.

## What the build does

1. `./scripts/build-repo.sh` — personal packages → `repo/out/`
2. `./scripts/prepare-iso-include.sh` — builds `iso/include/`:
   - live xbps.d pointing at `/usr/share/atelier/repo`
   - copy of personal `.xbps` + repodata
   - live-only `profile.d` helper for autostart X with `live.autologin`
3. Clones **void-mklive** into `iso/void-mklive/` (gitignored) if missing
4. Embeds **void-installer** from void-mklive’s `installer.sh` into the include tree
5. Runs `mklive.sh` with:
   - official Void repo + `repo/out`
   - packages from `iso/package-lists/live.txt` (includes `atelier-desktop`)
   - services: `dbus`, `elogind`, `NetworkManager`
   - kernel cmdline: `live.autologin`
   - bootloader title: **Atelier Linux**
   - postsetup: `iso/scripts/postsetup.sh`

## Live session (expected)

| Item | Value |
|------|--------|
| Autologin | `live.autologin` on cmdline; default live user (`anon`, password `voidlinux` unless changed by mklive) |
| Desktop | `startx` → bspwm (Tokyo Night configs from skel) |
| Installer | **`atelier-install`** (package `atelier-installer`); optional `void-installer` text fallback |
| Personal repo (Atelier) | `/usr/share/atelier/repo` + `/etc/xbps.d/10-repository-atelier.conf` |
| GraeWolf void-repo | `/etc/xbps.d/20-repository-graewolf.conf` + public key (brave-origin, etc.) |

If X does not start automatically, log in on tty1 and run `startx`.

## Package lists

| File | Role |
|------|------|
| `iso/package-lists/live.txt` | Full `-p` list for mklive |
| `iso/package-lists/live-extra.txt` | Graphics/live extras (document; mirrored into live.txt) |
| `iso/package-lists/desktop.txt` | Desktop stack flat list (docs / non-meta fallback) |

## Layout

```text
iso/
├── include-src/          # static overlay sources (tracked)
├── include/              # generated for -I (gitignored)
├── package-lists/
├── scripts/postsetup.sh
├── void-mklive/          # cloned upstream (gitignored)
├── work/                 # xbps cache etc. (gitignored)
├── output/               # *.iso (gitignored)
└── README.md
```

## Environment overrides

| Variable | Default | Meaning |
|----------|---------|---------|
| `MKLIVE_DIR` | `iso/void-mklive` | void-mklive checkout |
| `MKLIVE_URL` | GitHub void-linux/void-mklive | clone URL |
| `CACHE_DIR` | `iso/work/xbps-cache` | xbps cache for mklive |
| `ARCH` | `x86_64` | target arch |
| `TITLE` | `Atelier Linux` | bootloader title |

## Testing

1. Build ISO with `sudo ./scripts/build-iso.sh`
2. Boot in a VM (QEMU/KVM, VirtualBox, etc.)
3. Confirm: autologin or `startx`, polybar/bspwm colors, rofi (`Super+d`), personal repo query:

```bash
xbps-query --repository=/usr/share/atelier/repo -Rs atelier
```

4. Optional: run `void-installer` for a smoke install (full custom installer is Step 5)
5. NVIDIA / Xlibre: deferred to Step 6 on real hardware

## Troubleshooting

| Problem | Things to try |
|---------|----------------|
| `build-iso.sh` refuses non-root | Use `sudo` for full build; `--check` works unprivileged |
| Missing xorriso / mksquashfs | `xbps-install -S xorriso squashfs-tools xz` |
| atelier packages not found | `./scripts/build-repo.sh` then re-run |
| Black screen / no X | tty2 login, `startx`, check `xorg-minimal` / mesa in live list |
| WSL2 cannot show GUI | Export ISO to a VM or hardware |

## NVIDIA / Xlibre

Default live images stay on **X.Org + mesa**. Proprietary NVIDIA is handled by:

- Installer prompts (`atelier-install`)
- Post-install: `sudo atelier-setup-nvidia` and optional `sudo atelier-setup-xlibre`
- Optional package list: `iso/package-lists/nvidia.txt`

See [nvidia.md](nvidia.md).

## Out of scope (later)

- Further hardware beyond primary NVIDIA desktop
- Full-disk encryption

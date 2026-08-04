# End-to-end build guide (Phase 1)

Reproduce Atelier from a clean monorepo clone: personal packages → live ISO → install → optional NVIDIA.

## Host requirements

| Need | Notes |
|------|--------|
| OS | **Void Linux** (WSL2 Void is fine for packaging; GUI/NVIDIA need VM or bare metal) |
| Privileges | Root for ISO build (`sudo ./scripts/build-iso.sh`) |
| Network | Void mirrors + optional xlibre-void / nonfree |
| Disk | Several GB free for xbps cache + ISO |
| Tools | `git`, `xbps-*`, and for ISO: `xorriso`, `squashfs-tools`, `xz` |

```bash
sudo xbps-install -S git xorriso squashfs-tools xz mtools dosfstools
```

## 1. Clone and inspect

```bash
git clone <your-atelier-remote> atelier
cd atelier
cat PLAN.md
cat docs/build/phases.md
```

## 2. Build the personal repository

```bash
./scripts/build-repo.sh
./scripts/verify-repo.sh
xbps-query --repository=$PWD/repo/out -Rs atelier
```

Produces `repo/out/*.xbps` (gitignored):  
`atelier-base`, `atelier-config`, `atelier-desktop`, `atelier-installer`, `atelier-nvidia`, `atelier-xlibre-repo`.

Details: [personal-repo.md](personal-repo.md).

### Config / installer workflow

| Edit | Then |
|------|------|
| `configs/` | `./scripts/sync-atelier-config-files.sh` |
| `installer/` | `./scripts/sync-atelier-installer-files.sh` |
| NVIDIA/Xlibre configs | `sync-atelier-nvidia-files.sh` / `sync-atelier-xlibre-files.sh` |

`build-repo.sh` runs these sync steps by default.

## 3. Validate ISO preparation (no root)

```bash
./scripts/build-iso.sh --check
```

Confirms package lists, include tree (personal repo + live helpers), and void-mklive checkout.

## 4. Build the live ISO (root)

```bash
sudo ./scripts/build-iso.sh
```

Output: `iso/output/atelier-YYYYMMDD-x86_64.iso`

Details: [live-iso.md](live-iso.md).

**Do not** write/burn media without deliberate care.

## 5. Test in a VM

1. Boot the ISO in QEMU/KVM, VirtualBox, or similar.
2. Confirm themed session (`startx` if needed).
3. Run **Install Atelier Linux** (`atelier-install`) into a virtual disk.
4. Reboot the VM from the virtual disk; confirm login + bspwm.

NVIDIA proprietary drivers are **not** required for VM smoke tests (and usually will not apply).

## 6. Hardware (primary NVIDIA desktop)

1. Boot/install from the ISO (or install in VM and transplant — prefer real install).
2. In the installer, accept NVIDIA and optionally Xlibre; **or** after install:

   ```bash
   sudo atelier-setup-nvidia
   sudo reboot
   sudo atelier-setup-xlibre   # optional
   ```

3. Follow the checklist in [nvidia.md](nvidia.md).

## 7. Day-to-day development

```bash
git pull
# edit configs / packages / docs
./scripts/build-repo.sh
sudo ./scripts/build-iso.sh    # when ISO changes matter
git add -A && git commit && git push
```

Multi-machine: Git is the source of truth; re-read `PLAN.md` / `docs/build/phases.md` when switching hosts.

## Package and source map

- Names and gaps: [package-sources.md](package-sources.md)
- Architecture: [architecture.md](architecture.md)
- Installer internals: [installer.md](installer.md)

## Known Phase 1 gaps (honest)

| Gap | Status |
|-----|--------|
| brave-origin browser package | Not in Void; personal package still TBD |
| JetBrains Mono font package | Referenced in configs; personal package TBD |
| Public hosting of personal repo | Layout/docs only; local `repo/out` for MVP |
| Full-disk encryption | Deferred past MVP |
| Hardware CI | Manual test on desktop machine |

## Success criteria checklist

- [x] Tooling for bootable live ISO (void-mklive wrappers)
- [x] Graphical installer (`atelier-install`)
- [x] NVIDIA proprietary path (nonfree + atelier-nvidia + setup)
- [x] Personal repo integrated (build + embed on ISO)
- [x] Themed bspwm desktop configs + metapackages
- [x] Tokyo Night across documented components
- [x] User docs + detailed build docs (this tree)

Actual ISO boots and GPU installs depend on your host/hardware runs.

# Phase 1 milestones

Phase 1 (MVP) is split into small, reviewable steps.

## Status

| Step | Name | Status |
|------|------|--------|
| 0 | Repository scaffolding | Complete |
| 1 | Package lists & base metapackages | Complete |
| 2 | Desktop config packages (theme engine) | Complete (Tokyo Night default; switchable palettes) |
| 3 | Local personal XBPS repository | Complete |
| 4 | First bootable live ISO | Complete |
| 5 | Custom simple GUI installer | Complete |
| 6 | NVIDIA proprietary support | Complete |
| 7 | Documentation polish | Complete |

## Step details

### Step 0 — Repository scaffolding
Directory layout, docs stubs, README layout overview.

### Step 1 — Package lists & base metapackages
Declarative package lists from `PLAN.md`; `atelier-base` / `atelier-desktop`; source notes.

### Step 2 — Desktop config packages
Themed bspwm stack configs shipped as `atelier-config` (`atelier-theme`; Tokyo Night default).

### Step 3 — Local personal XBPS repository
`scripts/build-repo.sh` → `repo/out/`. Public extras (brave-origin, etc.) via GraeWolf/void-repo + `atelier-void-repo`.
### Step 4 — First bootable live ISO
void-mklive wrappers; personal repo embedded; themed live desktop path.

### Step 5 — Custom simple GUI installer
`atelier-install` whole-disk MVP. Optional LUKS2 added post-MVP (0.4.0).

### Step 6 — NVIDIA proprietary support
`atelier-nvidia`, `atelier-xlibre-repo`, installer options, setup scripts.

### Step 7 — Documentation polish
User guides + end-to-end build docs; README status updated.

## Phase 1 success criteria (from PLAN.md)

| Criterion | Delivery |
|-----------|----------|
| Bootable live ISO | `scripts/build-iso.sh` + docs |
| Graphical installer | `atelier-installer` / `atelier-install` |
| NVIDIA proprietary support | nonfree + `atelier-nvidia` + setup/installer |
| Personal extra repository | `repo/out`, embedded on ISO |
| Fully themed bspwm desktop | `atelier-desktop` + `atelier-config` |
| Consistent theming (Tokyo Night default) | `atelier-theme` + configs across stack |
| Basic user + detailed build docs | `docs/user/`, `docs/build/` |

**Resolved:** public package hosting and brave-origin via [GraeWolf/void-repo](https://github.com/GraeWolf/void-repo) (`atelier-void-repo` on live/ISO).

Remaining gaps (JetBrains font package, extra hardware polish) are documented in [end-to-end.md](end-to-end.md) and [package-sources.md](package-sources.md).

## Out of scope for Phase 1

- Full-disk encryption (now a post-MVP installer option; see below)
- Extra hardware support beyond primary NVIDIA desktop  
- Calamares  
- Public repo hosting (layout and docs only)  
- Additional window managers or desktop environments  
- Windows VM / Docker guest stack (post-MVP optional; see below)

## Post-MVP: optional LUKS2 at install

| Item | Policy |
|------|--------|
| Where | `atelier-install` wizard (after disk, before identity) |
| Default | Off (unencrypted whole-disk, unchanged layout) |
| What is encrypted | Root filesystem only (LUKS2, argon2id) |
| What is not | `/boot` (1GiB ext4), EFI System Partition / bios_grub |
| Not included | LVM, swap, GRUB cryptodisk, TPM, encrypted `/boot` |
| Live package | `cryptsetup` on the live ISO + `atelier-installer` depends |
| Docs | [installer.md](installer.md); [../user/installer.md](../user/installer.md) |
| Status | Implemented (`atelier-installer` 0.4.0) |

## Post-MVP optional: Windows VM

| Item | Policy |
|------|--------|
| Package | `atelier-windows-vm` (personal repo) |
| Role | Opt-in Windows 11 guest via Docker + dockur/windows + FreeRDP |
| Desktop meta | **Not** a dependency of `atelier-desktop` |
| Live ISO | **Not** on `iso/package-lists/*` |
| Host packages | Void XBPS: `docker`, `docker-compose`, `freerdp`, `dialog`, … |
| Runtime image | Third-party Docker image `dockurr/windows` pulled only when the user runs install |
| Docs | [windows-vm.md](windows-vm.md) (build); [../user/windows-vm.md](../user/windows-vm.md) (user) |
| Status | Implemented (`atelier-windows-vm` 0.2.0); bare-metal support gate in build docs |

This is deliberate optional glue for Office-class apps—not Phase 1 MVP scope.

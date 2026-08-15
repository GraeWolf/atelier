# Phase 1 milestones

Phase 1 (MVP) is split into small, reviewable steps.

## Status

| Step | Name | Status |
|------|------|--------|
| 0 | Repository scaffolding | Complete |
| 1 | Package lists & base metapackages | Complete |
| 2 | Desktop config packages (Tokyo Night) | Complete |
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
Tokyo Night bspwm stack configs shipped as `atelier-config`.

### Step 3 — Local personal XBPS repository
`scripts/build-repo.sh` → `repo/out/`. Public extras (brave-origin, etc.) via GraeWolf/void-repo + `atelier-void-repo`.
### Step 4 — First bootable live ISO
void-mklive wrappers; personal repo embedded; themed live desktop path.

### Step 5 — Custom simple GUI installer
`atelier-install` whole-disk MVP (no encryption).

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
| Consistent Tokyo Night theming | configs across stack |
| Basic user + detailed build docs | `docs/user/`, `docs/build/` |

**Resolved:** public package hosting and brave-origin via [GraeWolf/void-repo](https://github.com/GraeWolf/void-repo) (`atelier-void-repo` on live/ISO).

Remaining gaps (JetBrains font package, encryption, extra hardware polish) are documented in [end-to-end.md](end-to-end.md) and [package-sources.md](package-sources.md).

## Out of scope for Phase 1

- Full-disk encryption  
- Extra hardware support beyond primary NVIDIA desktop  
- Calamares  
- Public repo hosting (layout and docs only)  
- Additional window managers or desktop environments  

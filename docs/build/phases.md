# Phase 1 milestones

Phase 1 (MVP) is split into small, reviewable steps. Complete and verify each step before starting the next.

## Status

| Step | Name | Status |
|------|------|--------|
| 0 | Repository scaffolding | Complete |
| 1 | Package lists & base metapackages | Complete |
| 2 | Desktop config packages (Tokyo Night) | Complete |
| 3 | Local personal XBPS repository | Not started |
| 4 | First bootable live ISO | Not started |
| 5 | Custom simple GUI installer | Not started |
| 6 | NVIDIA proprietary support | Not started |
| 7 | Documentation polish | Not started |

## Step details

### Step 0 — Repository scaffolding
Directory layout, docs stubs, README layout overview. No packages or ISO builds.

### Step 1 — Package lists & base metapackages
Declarative package lists from `PLAN.md` section 7; `atelier-base` / `atelier-desktop` metapackages; note official Void vs personal vs external (Xlibre) sources.

### Step 2 — Desktop config packages
XBPS packages for bspwm stack and Tokyo Night theming, built from `configs/`.

### Step 3 — Local personal XBPS repository
Build scripts and `repo/` layout usable at ISO build time; publish-ready structure for later public hosting.

### Step 4 — First bootable live ISO
void-mklive wrappers under `iso/`; themed live desktop; personal repo integrated. Prefer packages over overlays.

### Step 5 — Custom simple GUI installer
Minimal installer under `installer/`; whole-disk MVP; no encryption.

### Step 6 — NVIDIA proprietary support
Live and installed paths for proprietary NVIDIA with Xlibre; hardware validation on desktop machine.

### Step 7 — Documentation polish
Finish `docs/build/` and `docs/user/`; mark Phase 1 complete in README when success criteria are met.

## Phase 1 success criteria (from PLAN.md)

- Bootable live ISO
- Graphical installer
- NVIDIA proprietary driver support
- Personal extra repository integrated
- Fully themed bspwm desktop with complete application list
- Consistent Tokyo Night theming
- Basic user documentation + detailed build documentation

## Out of scope for Phase 1

- Full-disk encryption
- Extra hardware support beyond primary NVIDIA desktop
- Calamares
- Public repo hosting (layout and docs only)
- Additional window managers or desktop environments

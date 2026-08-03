# Architecture (Phase 1)

This document records the technical choices locked for the Phase 1 MVP.

## Stack

| Component | Choice | Notes |
|-----------|--------|-------|
| Base | Void Linux | Rolling release |
| Init | runit | Void default |
| Packages | XBPS (pure) + personal repo | No foreign package formats |
| Display server | Xlibre | External / personal packaging as needed |
| Window manager | bspwm | Single fixed setup |
| Primary hardware | Desktop PC | NVIDIA proprietary required |
| Theming | Tokyo Night (dark) | GTK, Qt, terminals, TUIs, rofi, polybar, etc. |

## ISO and installer

- **ISO build:** [void-mklive](https://github.com/void-linux/void-mklive)
- **Installer:** Custom simple GUI installer (not Calamares)
  - MVP scope is intentionally limited (e.g. whole-disk install, no encryption)
  - Source lives under `installer/`

## Configuration delivery

Desktop and theming configuration is shipped as **XBPS packages** built from sources under `configs/` and packaged via templates under `packages/`.

Prefer packages over rootfs overlays so the installed system can be updated the same way as the live image.

## Personal repository

- **Phase 1:** Local / build-time XBPS repository under `repo/`
- Layout and docs are written so public hosting (static host, rsync, etc.) can be added later without restructuring
- **Never commit private signing keys or secrets** (see `AGENTS.md`)

## Source of truth

- Product goals and package lists: `PLAN.md`
- Agent / workflow rules: `AGENTS.md`
- Milestone breakdown: `docs/build/phases.md`
- Package name mapping and gaps: `docs/build/package-sources.md`

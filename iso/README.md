# Live ISO

Wrappers and assets for building the Atelier live ISO with **void-mklive**.

## Planned contents

| Path | Role |
|------|------|
| `package-lists/` | Package sets passed to mklive / documented for builds |
| `scripts/` | Helper scripts around void-mklive (clone, invoke, post-hooks) |
| This README | Build overview (expanded in Step 4) |

## Design notes

- Prefer installing Atelier **XBPS packages** (from the personal repo) over large rootfs overlays
- Live environment should ideally show the final themed bspwm desktop
- Personal repository must work in the live system
- NVIDIA support is a later Phase 1 step; first ISO may target a simpler graphics path for VM testing

## Safety

Do not burn/write ISOs to disks or run full system package operations without explicit approval. See `AGENTS.md`.

ISO build automation lands in **Phase 1 Step 4**.

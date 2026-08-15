# Architecture (Phase 1)

This document records the technical choices locked for the Phase 1 MVP.

## Stack

| Component | Choice | Notes |
|-----------|--------|-------|
| Base | Void Linux | Rolling release |
| Init | runit | Void default |
| Packages | XBPS (pure) + personal repo | No foreign package formats |
| Display server | Xlibre (external repo) | Fallback: X.Org on live/VM |
| Window manager | bspwm | Single fixed setup |
| Primary hardware | Desktop PC | NVIDIA proprietary (Void nonfree) |
| Theming | Tokyo Night (dark) | GTK, Qt, terminals, TUIs, rofi, polybar, etc. |

## ISO and installer

- **ISO build:** [void-mklive](https://github.com/void-linux/void-mklive) via `scripts/build-iso.sh`
  - Package list: `iso/package-lists/live.txt`
  - Personal repo embedded at `/usr/share/atelier/repo`
  - Default live image: X.Org + mesa (VM-friendly)
  - NVIDIA/Xlibre: installer options + `atelier-setup-nvidia` / `atelier-setup-xlibre`
  - Docs: `docs/build/live-iso.md`, `docs/build/nvidia.md`
- **Installer:** `atelier-install` (package `atelier-installer`)
  - **TUI default** (`dialog`); optional `--gui` (yad/zenity)
  - Whole-disk only; no encryption
  - Live ISO boots to TTY; run `sudo atelier-install`
  - Source: `installer/`; docs: `docs/build/installer.md`, `docs/user/installer.md`

## Configuration delivery

Desktop and theming configuration is shipped as **XBPS packages** built from sources under `configs/` and packaged via templates under `packages/`.

Prefer packages over rootfs overlays so the installed system can be updated the same way as the live image.

## Package repositories

- **Local Atelier repo:** build-time under `repo/out/`, embedded on the ISO at `/usr/share/atelier/repo`
  - Built with `scripts/build-repo.sh` (`xbps-create` + `xbps-rindex`; unsigned by default)
  - See `docs/build/personal-repo.md`
- **Public GraeWolf void-repo:** [github.com/GraeWolf/void-repo](https://github.com/GraeWolf/void-repo)
  - Signed binaries: `https://github.com/GraeWolf/void-repo/releases/download/x86_64/`
  - Enabled on live/installed systems via package `atelier-void-repo` (xbps.d + public key)
  - Provides PLAN packages not in official Void (e.g. `brave-origin`)
- **Never commit private signing keys or secrets** (see `AGENTS.md`)

## Source of truth

- Product goals and package lists: `PLAN.md`
- Agent / workflow rules: `AGENTS.md`
- Milestone breakdown: `docs/build/phases.md`
- Package name mapping and gaps: `docs/build/package-sources.md`
- End-to-end build: `docs/build/end-to-end.md`
- User documentation: `docs/user/`

# Packages

XBPS package sources (templates and package files) for Atelier.

## Layout

```
packages/
├── README.md
├── atelier-base/
│   └── template
├── atelier-config/
│   ├── template
│   └── files/          # from configs/ via sync script
├── atelier-desktop/
│   └── template
├── atelier-installer/
│   ├── template
│   └── files/          # from installer/ via sync script
├── atelier-windows-vm/
│   ├── template
│   ├── helpers/        # CLI + setup stubs (canonical)
│   └── files/          # from helpers/ via sync script
└── atelier-asus/
    ├── template
    ├── helpers/        # atelier-kbd + udev (canonical)
    └── files/          # from helpers/ via sync script
```

Build with `./scripts/build-repo.sh` (Step 3 tooling).

## Current packages

| Package | Type | Role |
|---------|------|------|
| `atelier-base` | metapackage | Fonts (FiraCode, Nerd Symbols) + xinit/xsetroot/xrdb |
| `atelier-config` | files | Themed session configs + `atelier-theme` + `atelier-webapp` + `atelier-setup-nvidia` + `atelier-setup-swap` |
| `atelier-desktop` | metapackage | Full PLAN desktop stack + apps + PipeWire audio + `atelier-config` |
| `atelier-installer` | files | `atelier-install` TUI/GUI + desktop entry (optional LUKS2 + optional swapfile) |
| `atelier-nvidia` | files + meta | Proprietary NVIDIA configs; depends on `nvidia` |
| `atelier-xlibre-repo` | files | Xlibre external repo (public key + xbps.d) |
| `atelier-void-repo` | files | GraeWolf personal Void repo (public key + xbps.d) |
| `atelier-windows-vm` | files | Optional Windows VM (Docker + FreeRDP, v0.2.0); **not** a dep of `atelier-desktop` |
| `atelier-asus` | files | Optional ASUS ROG keyboard backlight restore; **not** a dep of `atelier-desktop` |

## Config packaging workflow

1. Edit canonical files under `configs/`, `installer/`, or package `helpers/`
2. Run the matching `scripts/sync-atelier-*-files.sh`
3. Commit sources and generated `packages/*/files/`
4. `./scripts/build-repo.sh`

`atelier-windows-vm` and `atelier-asus` are post-MVP optional glue (PLAN notes). Do not add them to `atelier-desktop` depends or live ISO lists.

## Source of truth for names and gaps

See [docs/build/package-sources.md](../docs/build/package-sources.md).

Flat lists for ISO tooling: [iso/package-lists/](../iso/package-lists/).

## Conventions

- Follow Void `template` style
- Prefer declarative `depends` for metapackages
- Do not add packages beyond `PLAN.md` unless required technical glue (document why)
- Never put secrets or private keys in this tree

## External repositories (not built in this monorepo)

| Source | Role |
|--------|------|
| [GraeWolf/void-repo](https://github.com/GraeWolf/void-repo) | Public signed packages (`brave-origin`, …); enabled by `atelier-void-repo` (**resolved**) |
| Xlibre (xlibre-void) | Display server; enabled by `atelier-xlibre-repo` |

## Still open (optional)

- `font-jetbrains-mono` — PLAN font name; UI currently uses Fira Code

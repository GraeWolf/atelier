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
└── atelier-installer/
    ├── template
    └── files/          # from installer/ via sync script
```

Build with `./scripts/build-repo.sh` (Step 3 tooling).

## Current packages

| Package | Type | Role |
|---------|------|------|
| `atelier-base` | metapackage | Fonts (FiraCode, Nerd Symbols) + xinit/xsetroot/xrdb |
| `atelier-config` | files | Tokyo Night session configs → `/etc/skel` + xsessions |
| `atelier-desktop` | metapackage | Full PLAN desktop stack + apps + PipeWire audio + `atelier-config` |
| `atelier-installer` | files | `atelier-install` GUI + desktop entry |
| `atelier-nvidia` | files + meta | Proprietary NVIDIA configs; depends on `nvidia` |
| `atelier-xlibre-repo` | files | Xlibre external repo (public key + xbps.d) |
| `atelier-void-repo` | files | GraeWolf personal Void repo (public key + xbps.d) |

## Config packaging workflow

1. Edit canonical files under `configs/` or `installer/`
2. Run `scripts/sync-atelier-config-files.sh` / `scripts/sync-atelier-installer-files.sh`
3. Commit sources and generated `packages/*/files/`
4. `./scripts/build-repo.sh`

## Source of truth for names and gaps

See [docs/build/package-sources.md](../docs/build/package-sources.md).

Flat lists for ISO tooling: [iso/package-lists/](../iso/package-lists/).

## Conventions

- Follow Void `template` style
- Prefer declarative `depends` for metapackages
- Do not add packages beyond `PLAN.md` unless required technical glue (document why)
- Never put secrets or private keys in this tree

## Planned personal packages (gaps)

- `font-jetbrains-mono` — JetBrains Mono

External (not built in this monorepo):

- **GraeWolf void-repo** — `brave-origin`, `obsidian`, `melia` via `atelier-void-repo`
- **Xlibre** — via `atelier-xlibre-repo`

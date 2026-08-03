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
│   └── files/          # install tree (generated from configs/)
└── atelier-desktop/
    └── template
```

Build integration (xbps-src / local repo) arrives in **Step 3**.

## Current packages

| Package | Type | Role |
|---------|------|------|
| `atelier-base` | metapackage | Fonts (FiraCode, Nerd Symbols) + xinit/xsetroot/xrdb |
| `atelier-config` | files | Tokyo Night session configs → `/etc/skel` + xsessions |
| `atelier-desktop` | metapackage | Full PLAN desktop stack + apps + `atelier-config` |

## Config packaging workflow

1. Edit canonical files under `configs/`
2. Run `scripts/sync-atelier-config-files.sh`
3. Commit both `configs/` and `packages/atelier-config/files/`
4. Rebuild `atelier-config` when the personal repo exists

## Source of truth for names and gaps

See [docs/build/package-sources.md](../docs/build/package-sources.md).

Flat lists for ISO tooling: [iso/package-lists/](../iso/package-lists/).

## Conventions

- Follow Void `template` style
- Prefer declarative `depends` for metapackages
- Do not add packages beyond `PLAN.md` unless required technical glue (document why)
- Never put secrets or private keys in this tree

## Planned personal packages (gaps)

- `brave-origin` (or similar) — Brave browser
- `font-jetbrains-mono` — JetBrains Mono

Xlibre is expected from an **external** repo, not necessarily built here.

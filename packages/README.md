# Packages

XBPS package sources (templates and package files) for Atelier.

## Layout

Each package lives in its own directory with a Void-style `template`:

```
packages/
├── README.md
├── atelier-base/
│   └── template
└── atelier-desktop/
    └── template
```

Build integration (xbps-src / local repo) arrives in **Step 3**. Templates are written now so lists and depends can be reviewed early.

## Current packages

| Package | Type | Role |
|---------|------|------|
| `atelier-base` | metapackage | Fonts (FiraCode, Nerd Symbols) + xinit/xsetroot/xrdb |
| `atelier-desktop` | metapackage | Full PLAN desktop stack + apps available in Void |

## Source of truth for names and gaps

See [docs/build/package-sources.md](../docs/build/package-sources.md).

Flat lists for ISO tooling: [iso/package-lists/](../iso/package-lists/).

## Conventions

- Follow Void `template` style (`metapackage=yes` for pure depends packages)
- Prefer declarative `depends`; no heavy logic in metapackages
- Do not add packages beyond `PLAN.md` unless required technical glue (document why)
- Never put secrets or private keys in this tree
- Config/theme content goes under `configs/` and becomes packages in Step 2

## Planned personal packages (gaps)

- `brave-origin` (or similar) — Brave browser
- `font-jetbrains-mono` — JetBrains Mono
- Config packages — Tokyo Night + bspwm stack configs (Step 2)

Xlibre is expected from an **external** repo, not necessarily built here.

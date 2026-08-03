# Package lists

Flat package lists for documentation and future void-mklive invocations.

| File | Purpose |
|------|---------|
| `base.txt` | Fonts + minimal X session glue |
| `desktop.txt` | Full PLAN desktop stack + apps (Void-available only) |

Authoritative source notes and gaps: [docs/build/package-sources.md](../../docs/build/package-sources.md)

Metapackage equivalents (personal repo):

- `atelier-base` → roughly `base.txt`
- `atelier-desktop` → roughly `desktop.txt` + depends on `atelier-base`

When personal packages (Brave, JetBrains Mono) and Xlibre are ready, extend these lists and the metapackage templates together.

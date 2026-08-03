# Package lists

Flat package lists for documentation and void-mklive.

| File | Purpose |
|------|---------|
| `base.txt` | Fonts + minimal X session glue |
| `desktop.txt` | PLAN desktop stack + apps (Void-available) |
| `live-extra.txt` | Live/ISO extras (X.Org, NM, void-installer, …) |
| `live.txt` | Full mklive `-p` list (`atelier-desktop` + live extras) |

Authoritative source notes and gaps: [docs/build/package-sources.md](../../docs/build/package-sources.md)

Metapackage equivalents (personal repo):

- `atelier-base` → roughly `base.txt`
- `atelier-desktop` → roughly `desktop.txt` + `atelier-config`
- Live image → `live.txt` via `scripts/build-iso.sh`

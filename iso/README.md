# Live ISO

Wrappers and assets for building the Atelier live ISO with **void-mklive**.

## Quick start

```bash
# Validate prep (no root)
./scripts/build-iso.sh --check

# Build ISO (root required)
sudo ./scripts/build-iso.sh
```

Full documentation: [docs/build/live-iso.md](../docs/build/live-iso.md)

## Layout

| Path | Role |
|------|------|
| `package-lists/` | Package sets for mklive / documentation |
| `include-src/` | Static live overlay (xbps.d, profile.d) |
| `include/` | Generated `-I` tree (gitignored) |
| `scripts/postsetup.sh` | mklive `-x` hook |
| `void-mklive/` | Upstream clone (gitignored) |
| `work/` | Caches (gitignored) |
| `output/` | Built `*.iso` (gitignored) |

## Design notes

- Prefer **XBPS packages** (`atelier-desktop`) over large rootfs overlays
- Personal repo is installed into the image at `/usr/share/atelier/repo`
- First ISO uses **X.Org** for VM testing; **Xlibre** is wired later
- **atelier-installer** (GUI); optional **void-installer** text fallback
- Live cmdline includes `live.autologin`; profile.d may `startx` on tty1

## Safety

Do not burn/write ISOs to disks without explicit approval. See `AGENTS.md`.

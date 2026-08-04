# Build documentation

Step-by-step documentation for **building** Atelier: packages, personal repository, live ISO, installer, and NVIDIA/Xlibre.

Learning how the distro is assembled is a core project goal.

## Start here

1. **[end-to-end.md](end-to-end.md)** — full path from clone → ISO → install  
2. **[phases.md](phases.md)** — Phase 1 milestone status  
3. **[architecture.md](architecture.md)** — locked technical choices  

## Reference

| Document | Description |
|----------|-------------|
| [package-sources.md](package-sources.md) | PLAN → XBPS names, gaps, external repos |
| [personal-repo.md](personal-repo.md) | Build and use `repo/out` |
| [live-iso.md](live-iso.md) | void-mklive wrappers and live image notes |
| [installer.md](installer.md) | Graphical installer package notes |
| [nvidia.md](nvidia.md) | Proprietary NVIDIA + Xlibre |

## Config packaging cheatsheet

```bash
# Edit sources, then rebuild personal packages
./scripts/sync-atelier-config-files.sh      # configs/ → atelier-config
./scripts/sync-atelier-installer-files.sh   # installer/
./scripts/sync-atelier-nvidia-files.sh
./scripts/sync-atelier-xlibre-files.sh
./scripts/build-repo.sh
```

Or simply `./scripts/build-repo.sh` (runs syncs by default).

## Host notes

- Prefer **Void Linux** as the build host (including WSL2 Void for packaging).
- ISO generation needs **root** and mklive tools (`xorriso`, `squashfs-tools`, `xz`).
- Full GUI and NVIDIA validation: VM and/or second (desktop) machine — not WSL2 alone.

See also: root [PLAN.md](../../PLAN.md), user docs in [../user/](../user/).

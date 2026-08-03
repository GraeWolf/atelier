# Helper scripts

Project automation scripts (build personal repo, sync configs, verification).

| Script | Purpose |
|--------|---------|
| `sync-atelier-config-files.sh` | Copy `configs/` → `packages/atelier-config/files/` |
| `sync-atelier-installer-files.sh` | Copy `installer/` → `packages/atelier-installer/files/` |
| `sync-atelier-nvidia-files.sh` | Copy NVIDIA configs → `packages/atelier-nvidia/files/` |
| `sync-atelier-xlibre-files.sh` | Copy Xlibre repo files → `packages/atelier-xlibre-repo/files/` |
| `build-repo.sh` | Build Atelier packages into `repo/out/` and index |
| `verify-repo.sh` | Query local repo; install base+config into a rootdir |
| `prepare-iso-include.sh` | Build `iso/include/` from include-src + repo/out |
| `build-iso.sh` | void-mklive wrapper (`--check` or full root build) |
| `lib/atelier-common.sh` | Shared helpers (template field parse, messaging) |

## Typical workflow

```bash
./scripts/build-repo.sh      # sync configs, build, index
./scripts/verify-repo.sh     # query + rootdir install test
./scripts/build-iso.sh --check
sudo ./scripts/build-iso.sh  # produces iso/output/*.iso
```

Do not place secrets or private keys here.

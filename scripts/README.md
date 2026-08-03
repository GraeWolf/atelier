# Helper scripts

Project automation scripts (build personal repo, sync configs, verification).

| Script | Purpose |
|--------|---------|
| `sync-atelier-config-files.sh` | Copy `configs/` → `packages/atelier-config/files/` |
| `build-repo.sh` | Build Atelier packages into `repo/out/` and index |
| `verify-repo.sh` | Query local repo; install base+config into a rootdir |
| `lib/atelier-common.sh` | Shared helpers (template field parse, messaging) |

## Typical workflow

```bash
./scripts/build-repo.sh      # sync configs, build, index
./scripts/verify-repo.sh     # query + rootdir install test
```

ISO build helpers land in Step 4. Prefer small, readable shell with clear usage comments.

Do not place secrets or private keys here.

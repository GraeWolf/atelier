# Personal XBPS repository

Local / build-time personal repository for Atelier packages.

## Quick start

```bash
# from monorepo root
./scripts/build-repo.sh
./scripts/verify-repo.sh

xbps-query --repository=$PWD/repo/out -Rs atelier
```

Full documentation: [docs/build/personal-repo.md](../docs/build/personal-repo.md)

## Layout

```
repo/
├── conf/             # xbps.d examples (local + future public URL)
├── out/              # build output (gitignored): *.xbps, *-repodata
├── work/             # staging (gitignored)
└── README.md
```

## Phase 1 approach

- Build packages from `../packages/` into `out/`
- Packages are **unsigned** by default (local/dev)
- **Public** packages (e.g. `brave-origin`) live in [GraeWolf/void-repo](https://github.com/GraeWolf/void-repo), not necessarily in this `out/` tree
- Optional later: also publish this `out/` tree for remote Atelier metapackage updates
## Enabling the repo

See examples in `conf/`:

| File | Use |
|------|-----|
| `10-repository-atelier-local.conf.example` | Absolute path to `repo/out` on a build machine |
| `10-repository-atelier-public.conf.example` | Future HTTPS URL template |

## Security

- **Never commit private signing keys, passphrases, or `.env` files**
- Public keys and documentation may live in-repo; private keys must not
- `out/` and `work/` are gitignored

## See also

- [docs/build/architecture.md](../docs/build/architecture.md)
- [docs/build/phases.md](../docs/build/phases.md)
- [docs/build/personal-repo.md](../docs/build/personal-repo.md)

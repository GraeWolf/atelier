# Personal XBPS repository

Local / build-time personal repository for Atelier packages.

## Phase 1 approach

- Build packages from `../packages/` into a local repo tree used by ISO builds and development
- Layout should be ready for future **public hosting** (static web host, rsync target, etc.) without a major restructure
- Public hosting is **not** required for MVP; document how to publish when scripts exist

## Layout (planned)

```
repo/
├── conf/           # Repository configuration snippets for xbps
├── README.md       # This file
└── (build output)  # Generated; typically gitignored once builds exist
```

Exact output paths and ignore rules will be defined when the build scripts land (Step 3).

## Security

- **Never commit private signing keys, passphrases, or `.env` files**
- Public keys and documentation may live in-repo; private keys must not

## See also

- [docs/build/architecture.md](../docs/build/architecture.md)
- [docs/build/phases.md](../docs/build/phases.md)

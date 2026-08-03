# Build documentation

Detailed, step-by-step documentation for building Atelier (packages, personal repository, live ISO).

This is a core learning goal of the project. Content will grow as each Phase 1 milestone is completed.

## Contents

| Document | Description |
|----------|-------------|
| [architecture.md](architecture.md) | Locked technical choices for Phase 1 |
| [phases.md](phases.md) | Phase 1 milestone breakdown and status |
| [package-sources.md](package-sources.md) | PLAN → XBPS name mapping, gaps, external repos |
| [personal-repo.md](personal-repo.md) | Build and use the local personal XBPS repository |
| [live-iso.md](live-iso.md) | Build the live ISO with void-mklive |

## Config packaging

Edit `configs/`, then run `scripts/sync-atelier-config-files.sh` before building `atelier-config`.

## Planned topics

- Host requirements (Void on WSL2 and second machine)
- Building personal packages and the local XBPS repository
- Building the live ISO with void-mklive
- Testing in a VM and on hardware
- Publishing the personal repository (post-MVP or later in Phase 1 docs only)

See also: root [PLAN.md](../../PLAN.md).

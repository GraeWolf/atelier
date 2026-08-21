# Atelier

**Atelier** is a personal, opinionated Linux distribution based on Void Linux.

It is designed to be extremely minimal, simple, and aesthetically consistent — delivering a fully configured, elegant bspwm desktop that is ready to use immediately after installation.

## Philosophy

- Extreme minimalism
- Simplicity and clarity over features
- Opinionated but easy to understand and modify
- Clean, elegant aesthetics (Tokyo Night default; switchable palettes via `atelier-theme`)

## Current status

**Phase 1 (MVP) tooling and documentation are complete** (Steps 0–7).

What that means in-tree:

- Bootable live ISO build path (void-mklive wrappers)
- Whole-disk installer (`atelier-install`: TUI default; live boots to TTY)
- Personal XBPS repository build and ISO integration
- Themed bspwm desktop packages (Tokyo Night default)
- Proprietary NVIDIA + optional Xlibre setup path
- User documentation and detailed build documentation

Milestone status: [docs/build/phases.md](docs/build/phases.md)  
End-to-end build: [docs/build/end-to-end.md](docs/build/end-to-end.md)  
User quick start: [docs/user/quick-start.md](docs/user/quick-start.md)

**Public package repo:** [GraeWolf/void-repo](https://github.com/GraeWolf/void-repo) (e.g. `brave-origin`) is enabled on live/installed systems via `atelier-void-repo`.  
**Local Atelier packages** still build into `repo/out/` and ship on the ISO at `/usr/share/atelier/repo`.

Remaining gaps (e.g. JetBrains Mono package, encryption) are listed in [docs/build/package-sources.md](docs/build/package-sources.md).

## Quick links

| Audience | Start here |
|----------|------------|
| End users | [docs/user/README.md](docs/user/README.md) |
| Builders | [docs/build/README.md](docs/build/README.md) |
| Agents / contributors | [AGENTS.md](AGENTS.md), [PLAN.md](PLAN.md) |

### Build a personal repo + ISO (summary)

```bash
./scripts/build-repo.sh
./scripts/build-iso.sh --check
sudo ./scripts/build-iso.sh
```

## Repository layout

```
atelier/
├── PLAN.md              # Full project plan and specifications
├── AGENTS.md            # Instructions for AI coding agents
├── packages/            # XBPS package sources (templates / files)
├── configs/             # Canonical desktop & theme config sources
├── repo/                # Local personal XBPS repo layout + docs
├── iso/                 # void-mklive wrappers, package lists, hooks
├── installer/           # Custom simple GUI installer
├── docs/
│   ├── build/           # Detailed build documentation
│   └── user/            # User-facing documentation
└── scripts/             # Helper scripts (build-repo, build-iso, …)
```

## Locked choices (Phase 1)

| Area | Choice |
|------|--------|
| Base | Void Linux + runit + pure XBPS |
| ISO | void-mklive |
| Installer | Custom simple GUI (not Calamares) |
| WM | bspwm (single fixed setup) |
| Display | Xlibre (external) with X.Org live/fallback |
| GPU | NVIDIA proprietary (Void nonfree) on primary desktop |
| Configs | XBPS packages from `configs/` |
| Personal repo | Local/build-time first; publish-ready layout |
| Theme | Tokyo Night dark (default); `atelier-theme` |

## Development

This project is developed across multiple machines using Git as the single source of truth.  
Grok Build is used as the primary coding agent.

Key files:

- `PLAN.md` — Full project plan and specifications
- `AGENTS.md` — Instructions for AI coding agents working on this repository

## License

TBD

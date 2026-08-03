# Atelier

**Atelier** is a personal, opinionated Linux distribution based on Void Linux.

It is designed to be extremely minimal, simple, and aesthetically consistent — delivering a fully configured, elegant bspwm desktop that is ready to use immediately after installation.

## Philosophy

- Extreme minimalism
- Simplicity and clarity over features
- Opinionated but easy to understand and modify
- Clean, elegant aesthetics (Tokyo Night dark theme applied consistently)

## Current Status

**Phase 1 (MVP)** is in progress.

**Current milestone:** Step 3 — Local personal XBPS repository (complete). Next: Step 4 — first bootable live ISO.

Target features for the first usable version:

- Bootable live ISO with graphical installer
- NVIDIA proprietary driver support
- Personal package repository integrated
- Fully themed bspwm desktop with a carefully chosen application set
- Basic user documentation and detailed build documentation

Milestone breakdown and status: [docs/build/phases.md](docs/build/phases.md)  
Architecture decisions: [docs/build/architecture.md](docs/build/architecture.md)

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
| ISO | void-mklive |
| Installer | Custom simple GUI (not Calamares) |
| Configs | XBPS config packages from `configs/` |
| Personal repo | Local/build-time first; publish-ready layout |

## Development

This project is developed across multiple machines using Git as the single source of truth.  
Grok Build is used as the primary coding agent.

Key files:

- `PLAN.md` — Full project plan and specifications
- `AGENTS.md` — Instructions for AI coding agents working on this repository

## License

TBD

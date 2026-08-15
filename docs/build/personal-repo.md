# Personal XBPS repository

How to build and use Atelier’s local personal repository (Phase 1 Step 3).

## Overview

Atelier packages under `packages/` are built with **`xbps-create`** and indexed with **`xbps-rindex`**. Output lands in **`repo/out/`**.

This path avoids cloning and bootstrapping full `void-packages` for metapackages and config-only packages. If a future package needs compilation, we can add an xbps-src workflow without changing `repo/out/` layout.

## Layout

```
repo/
├── conf/
│   ├── 10-repository-atelier-local.conf.example
│   └── 10-repository-atelier-public.conf.example
├── out/                 # generated (gitignored): *.xbps + *-repodata
├── work/                # generated (gitignored): staging
└── README.md
```

Publish-ready: host the contents of `repo/out/` over HTTPS (or rsync) and point an xbps.d file at that URL.

## Prerequisites

- Void Linux host with `xbps` (`xbps-create`, `xbps-rindex`, `xbps-query`, `xbps-install`)
- Network only if you install packages that pull depends from official mirrors

## Build

From the monorepo root:

```bash
./scripts/build-repo.sh
```

This will:

1. Sync `configs/` → `packages/atelier-config/files/`
2. Build `atelier-base`, `atelier-config`, `atelier-desktop` (noarch)
3. Index `repo/out/` (unsigned)

Skip config sync:

```bash
./scripts/build-repo.sh --no-sync
```

## Verify

```bash
./scripts/verify-repo.sh
```

Optional install into a throwaway root (uses official Void repos for depends):

```bash
./scripts/verify-repo.sh --root /tmp/atelier-test-root
```

Query manually:

```bash
xbps-query --repository=$PWD/repo/out -Rs atelier
xbps-query --repository=$PWD/repo/out -R atelier-desktop
```

## Install on a Void host (development)

**One-shot (no xbps.d change):**

```bash
sudo xbps-install --repository=$PWD/repo/out -S atelier-desktop
```

**Persistent local repo:**

```bash
# edit path, then:
sudo cp repo/conf/10-repository-atelier-local.conf.example \
  /etc/xbps.d/10-repository-atelier-local.conf
sudo xbps-install -S
sudo xbps-install -y atelier-desktop
```

## Signing (optional, not required for MVP)

- Default builds are **unsigned** and fine for local ISO/dev use
- **Never commit private keys**
- To sign later: `xbps-rindex --sign` / `--sign-pkg` with a key kept outside the repo
- Document the public key for users when public hosting goes live

## Public packages (GraeWolf void-repo)

Separate from this monorepo’s `repo/out/`:

| Item | Value |
|------|--------|
| Source | https://github.com/GraeWolf/void-repo |
| Binaries | `https://github.com/GraeWolf/void-repo/releases/download/x86_64/` |
| Atelier enablement | package `atelier-void-repo` |
| Example packages | `brave-origin`, and other GraeWolf builds |

Atelier **metapackages/configs** stay local/on-ISO for now. **Extra PLAN packages** (browser, etc.) come from the public void-repo.

Optional later: also publish `repo/out` (atelier-*) to a static URL; examples remain in `repo/conf/*-public.conf.example`.

## Packages produced (this monorepo)

| Package | Type |
|---------|------|
| `atelier-base` | metapackage |
| `atelier-config` | config files (`/etc/skel`, xsessions, bashrc.d, wallpapers, …) |
| `atelier-desktop` | metapackage (stack + apps + config + void-repo glue) |
| `atelier-installer` | graphical installer |
| `atelier-nvidia` / `atelier-xlibre-repo` / `atelier-void-repo` | hardware / external repos |

See [package-sources.md](package-sources.md) for depends and gaps.

# Windows VM (post-MVP optional) — build & policy

Status: **setup-docker implemented**; install/launch lifecycle CLI still incomplete.  
Policy locked for Atelier; full implementation follows incremental PRs.

## Purpose

Provide an **opt-in** way to run Windows 11 for Office-class applications on an Atelier host, without dual-boot or bloating the default desktop.

Prior art: Omarchy’s `omarchy-windows-vm` wrapping [dockur/windows](https://github.com/dockur/windows).

## Non-goals (v1)

- Not a hard dependency of `atelier-desktop`
- Not on live ISO package lists
- No GPU passthrough / gaming / Looking Glass
- No seamless per-app windowing (WinApps-class)
- No Windows ISO or license keys in the repo
- No default sxhkd keybind

## Pure XBPS + Docker image exception

| Layer | Source |
|-------|--------|
| Package `atelier-windows-vm` | Personal Atelier repo (`packages/`, `repo/out`) |
| Docker engine, FreeRDP, dialog, libnotify | Official Void XBPS |
| Guest OS image | Docker image `dockurr/windows` (pulled at user-driven install) |

**Policy statement:**

> Optional package `atelier-windows-vm` uses official Void packages for the host stack. Installing the package pulls the Docker engine via XBPS. Separately, at `atelier-windows-vm install`, Docker downloads the third-party image `dockurr/windows`. That image is not an XBPS package, is not mirrored by Atelier’s personal repo, and is opt-in. Users who never install `atelier-windows-vm` never pull this stack.

## Packaging in this monorepo

`scripts/build-repo.sh` does **not** run Void-style `do_install()`. Payload path:

1. Edit helpers under `packages/atelier-windows-vm/helpers/` (and related assets)
2. `scripts/sync-atelier-windows-vm-files.sh` → `packages/atelier-windows-vm/files/`
3. `build-repo.sh` stages via `stage_from_files` for `atelier-windows-vm`
4. `xbps-create` → `repo/out/`

## User flow

```bash
sudo xbps-install -Sy atelier-windows-vm   # from personal repo
sudo atelier-setup-docker                  # runit + docker/kvm groups (implemented)
# re-login
atelier-windows-vm install                 # dialog wizard; web UI :8006 (stub)
atelier-windows-vm launch                  # FreeRDP to localhost:3389 (stub)
```

### `atelier-setup-docker` (locked algorithm)

Idempotent root helper (`#!/bin/sh`):

1. Resolve target user: `$1` or `$SUDO_USER`
2. `xbps-install -Sy docker docker-cli docker-compose`
3. Ensure groups `docker` and `kvm`; `usermod -aG docker,kvm <user>`
4. `ln -sf /etc/sv/docker /var/service/docker` (required)
5. Wait for `docker info`; if it fails, enable `/etc/sv/containerd` if present and `sv restart docker`
6. Print re-login reminder and verification commands

Messaging: **Docker enablement required by Windows VM** (not a general Docker product installer).

## Paths (Atelier)

| Role | Path |
|------|------|
| Compose | `~/.config/atelier/windows/docker-compose.yml` |
| VM disk storage | `~/.local/share/atelier/windows` |
| Shared folder | `~/Atelier/Windows` only |
| Container name | `atelier-windows` |

## Prerequisites

- x86_64
- `/dev/kvm` (bare metal with VT-x/AMD-V; WSL2 often lacks KVM)
- Free space on the storage filesystem **and** Docker root (often `/var/lib/docker`)

## Live ISO

Do **not** add `atelier-windows-vm` or Docker to `iso/package-lists/*` for the default live image.

## Related docs

- User guide (placeholder): [../user/windows-vm.md](../user/windows-vm.md)
- Architecture exception: [architecture.md](architecture.md)
- Package sources: [package-sources.md](package-sources.md)
- Phases: [phases.md](phases.md)

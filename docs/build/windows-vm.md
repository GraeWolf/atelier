# Windows VM (post-MVP optional) — build & packaging

Status: **implemented** in package `atelier-windows-vm` **0.2.0**  
(dialog install, FreeRDP launch, non-interactive flags, optional image pin).

User guide: [../user/windows-vm.md](../user/windows-vm.md).

**Void verification snapshot:** package names and FreeRDP/docker wiring last checked against Void `x86_64` **2026-08-15**. Re-check with `xbps-query -Rs` before releases.

---

## Purpose

Opt-in Windows 11 guest for Office-class apps on Atelier hosts, without dual-boot or bloating `atelier-desktop`.

Prior art: Omarchy `omarchy-windows-vm` + [dockur/windows](https://github.com/dockur/windows).

---

## Non-goals

- Not a hard dependency of `atelier-desktop`
- Not on live ISO package lists
- No GPU passthrough / Looking Glass / gaming
- No seamless per-app Windows (WinApps-class)
- No Windows ISO or license keys in the monorepo
- No default sxhkd keybind

---

## Pure XBPS + Docker image exception

| Layer | Source |
|-------|--------|
| `atelier-windows-vm` | Personal Atelier repo (`packages/`, `repo/out`) |
| `docker`, `docker-cli`, `docker-compose`, `freerdp`, `dialog`, `libnotify`, `xdg-utils` | Official Void XBPS |
| Guest stack image | `dockurr/windows` (or pinned digest) via Docker registry |

**Policy statement:**

> Optional package `atelier-windows-vm` uses official Void packages for the host stack. Installing the package pulls the Docker engine via XBPS. Separately, at `atelier-windows-vm install`, Docker downloads the third-party image `dockurr/windows` (or a user-supplied `--image` / `ATELIER_WINDOWS_IMAGE`). That image is not an XBPS package, is not mirrored by Atelier’s personal repo, and is opt-in. Users who never install `atelier-windows-vm` never pull this stack.

See also [architecture.md](architecture.md).

**Size impact:**

1. `xbps-install atelier-windows-vm` → Docker engine stack (tens–hundreds of MB class).  
2. `install` → multi‑GB image layers + Windows disk under storage + Docker root.

---

## Packaging in this monorepo

`scripts/build-repo.sh` does **not** run Void-style `do_install()`.

```text
helpers/  →  sync-atelier-windows-vm-files.sh  →  packages/atelier-windows-vm/files/
       →  stage_from_files (build-repo.sh case)  →  xbps-create  →  repo/out/
```

Required `build-repo.sh` wiring:

- `PACKAGE_ORDER` includes `atelier-windows-vm`
- sync hook runs `scripts/sync-atelier-windows-vm-files.sh`
- `stage_from_files` case arm for `atelier-windows-vm` (without it the package is empty)

Template `do_install` is **documentation only**.

### Package payload

| Path | Role |
|------|------|
| `/usr/bin/atelier-windows-vm` | Lifecycle CLI (bash) |
| `/usr/bin/atelier-setup-docker` | Root Docker/runit/group setup (sh) |
| `/usr/share/applications/atelier-windows.desktop` | Rofi entry “Windows” |
| `/usr/share/atelier/windows/docker-compose.yml.example` | Example (no secrets) |
| `/usr/share/doc/atelier/windows-vm-README.txt` | Offline short help |

### Depends (host)

`docker`, `docker-cli`, `docker-compose`, `freerdp` (`xfreerdp3`), `dialog`, `xdg-utils`, `libnotify`.

---

## Runtime architecture

```text
atelier-windows-vm  →  docker compose  →  container atelier-windows
                              │                 │
                              │            QEMU/KVM (dockur)
                              │                 │
                         xfreerdp3  ←── RDP 127.0.0.1:3389
                         browser    ←── web 127.0.0.1:8006
```

Paths:

| Role | Path |
|------|------|
| Compose | `~/.config/atelier/windows/docker-compose.yml` (0600) |
| Disk | `~/.local/share/atelier/windows` |
| Shared | `~/Atelier/Windows` only |
| Container | `atelier-windows` |

---

## CLI contract

| Command | Notes |
|---------|--------|
| `install` | Dialog wizard **or** `--yes` + flags |
| `launch` | FreeRDP; auto-stop unless `--keep-alive` |
| `stop` | `compose down` |
| `status` | script-friendly; exit 1 if unconfigured |
| `remove` | keeps shared folder; `--yes` for scripts |

### Non-interactive install (v1.1)

```bash
atelier-windows-vm install --yes --force \
  --ram 4G --cpus 2 --disk 64G \
  --user docker \
  --image 'dockurr/windows@sha256:…'
# password: --password or ATELIER_WINDOWS_PASSWORD
```

### Image pin

- Default: floating `dockurr/windows`
- Override: `--image`, `ATELIER_WINDOWS_IMAGE`, or edit compose `image:`
- Document digests when shipping internal runbooks; Atelier does not pin digests in-repo (upstream moves)

### `launch` behaviour

1. Prereqs: compose, KVM, docker, FreeRDP  
2. `compose up -d` if needed  
3. Wait ≤120s for log `windows started successfully` (timeout → `:8006`, no RDP)  
4. RDP with `/from-stdin` when supported  
5. Soft scale from `xrdb` / `xdpyinfo`  
6. After FreeRDP: always `compose down` unless keep-alive (even if FreeRDP exit ≠ 0)  
7. Exit 0 after a session was started  

### `atelier-setup-docker`

Idempotent root helper:

1. User from `$1` or `$SUDO_USER`  
2. `xbps-install -Sy docker docker-cli docker-compose`  
3. `usermod -aG docker,kvm`  
4. Link `/etc/sv/docker` → `/var/service/docker`  
5. If `docker info` fails: enable `containerd` if present, restart docker  
6. Re-login reminder  

Messaging: **Docker enablement required by Windows VM**.

---

## Live ISO

Do **not** add `atelier-windows-vm` or Docker to `iso/package-lists/*`.

---

## Support gate (bare metal)

Feature is **not advertised as supported** until this matrix passes once on real hardware with KVM:

| # | Case | Pass |
|---|------|------|
| 1 | `build-repo.sh` + non-empty `xbps-query -f atelier-windows-vm` | yes |
| 2 | `atelier-setup-docker` → non-root `docker info` | yes |
| 3 | Missing KVM clear error | yes |
| 4 | Dual-FS disk messages | yes |
| 5 | Interactive or `--yes` install → compose 0600, `:8006` | yes |
| 6 | Unattended Windows finishes | yes |
| 7 | `launch` RDP; password not in `ps` cmdline | yes |
| 8 | RDP close → container stopped (even FreeRDP ≠ 0) | yes |
| 9 | `launch -k` keeps container | yes |
| 10 | Shared folder round-trip | yes |
| 11 | `remove` keeps `~/Atelier/Windows` | yes |

WSL2: packaging + lint only if no KVM.

---

## Developer workflow

```bash
# edit helpers
$EDITOR packages/atelier-windows-vm/helpers/atelier-windows-vm
./scripts/sync-atelier-windows-vm-files.sh
./scripts/build-repo.sh
xbps-query --repository=$PWD/repo/out -f atelier-windows-vm
bash -n packages/atelier-windows-vm/helpers/atelier-windows-vm
```

Optional: `shellcheck -s bash` / `shellcheck -s sh` when installed.

---

## Related

- [architecture.md](architecture.md) — Docker image exception  
- [package-sources.md](package-sources.md) — package table  
- [phases.md](phases.md) — post-MVP note  
- [../user/windows-vm.md](../user/windows-vm.md) — end-user guide  

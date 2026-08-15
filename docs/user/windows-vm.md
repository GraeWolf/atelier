# Windows VM (optional)

Opt-in Windows 11 guest for Office-class apps (Word, Excel, etc.) via **Docker + dockur/windows + FreeRDP**.  
It is **not** part of the default desktop (`atelier-desktop`) and is **not** on the live ISO.

**Requirements:** x86_64, `/dev/kvm` (typically bare metal), Docker enabled via `atelier-setup-docker`.

Package version: **0.2.0** (dialog install, FreeRDP launch, non-interactive flags).

---

## 1. Security & trust model (read first)

| Topic | Reality |
|-------|---------|
| **docker group** | Roughly **root-equivalent** on the host. Setup adds your user to `docker` (and `kvm`). |
| **Shared folder** | Only `~/Atelier/Windows` is mounted into the guest (**two-way**, untrusted). |
| **Credentials** | Stored in `~/.config/atelier/windows/docker-compose.yml` mode **0600**. |
| **Network** | RDP (`3389`) and web UI (`8006`) bind to **127.0.0.1** only. |
| **Isolation** | VM + container is convenient sandboxing, **not** a hardened security boundary. |
| **Malware** | Do **not** assume Windows malware cannot affect Linux. |

We will **not** claim: “malware-proof”, “air-gapped”, or “secure credential vault”.

Do not put SSH keys, password vaults, or secrets into `~/Atelier/Windows`.

---

## 2. What you get / limits

**Good for:** Microsoft Office, occasional Windows-only utilities.

**Not for:** gaming, GPU work, Looking Glass, seamless per-app windows (WinApps-class).

Other limits:

- Windows 11 Pro from dockur is **unactivated** — bring your own license  
- First install downloads a multi‑GB image + Windows ISO  
- Host package install also pulls the Docker **engine** (sizeable) before any Windows disk exists  

---

## 3. Prerequisites

1. Atelier (or Void) on **x86_64** with virtualization enabled in firmware  
2. Free space:
   - **Storage FS** (holds `~/.local/share/atelier/windows`): chosen disk size **+ ~10 GiB**  
   - **Docker root** (often `/var/lib/docker`): **~20 GiB** free for first pull/ISO  
3. Personal package available: `atelier-windows-vm` from your local/public Atelier repo  

WSL2 often **lacks** `/dev/kvm` — use bare metal for real use.

---

## 4. One-time Docker setup

```bash
sudo xbps-install -Sy atelier-windows-vm
sudo atelier-setup-docker
# log out and back in (docker + kvm groups)

docker info
docker compose version   # or: docker-compose version
```

---

## 5. Install Windows (interactive)

```bash
atelier-windows-vm install
```

Dialog wizard: security note → RAM / CPU / disk → username / password → start container.

Watch progress:

```text
http://127.0.0.1:8006
```

First Windows install can take **10–30+ minutes**. Prefer the web UI until it finishes, then launch RDP.

### Username / password rules (wizard)

| Field | Default | Allowed |
|-------|---------|---------|
| Username | `docker` | `A–Z a–z 0–9 . _ -` (1–32) |
| Password | `admin` | letters, digits, `!@#$%^&*_+.=-` (1–128) |

No quotes, backslashes, or control characters. Exotic passwords: set inside Windows later and edit compose carefully (keep double-quoted `USERNAME` / `PASSWORD` lines).

---

## 6. Install Windows (non-interactive / scripts)

```bash
atelier-windows-vm install --yes \
  --ram 4G --cpus 2 --disk 64G \
  --user docker \
  --password 'yourpass'

# Prefer env for password (less shell history risk):
ATELIER_WINDOWS_PASSWORD='yourpass' \
  atelier-windows-vm install --yes --ram 8G --cpus 4 --disk 128G --force
```

| Flag | Meaning |
|------|---------|
| `--yes` / `-y` | Non-interactive (required with resource flags) |
| `--force` | Overwrite existing compose |
| `--ram` | e.g. `4G` or `4` (default `4G`) |
| `--cpus` | cores (default `2`) |
| `--disk` | e.g. `64G` (default `64G`) |
| `--user` | Windows username |
| `--password` | Windows password |
| `--image` | Docker image ref (see pin below) |

Existing compose without `--force` fails in non-interactive mode.

---

## 7. Pinning the Docker image (optional)

Default image: floating tag **`dockurr/windows`**.

To pin a digest (supply-chain hygiene):

```bash
# discover digest once (example):
docker pull dockurr/windows
docker image inspect dockurr/windows --format '{{index .RepoDigests 0}}'

atelier-windows-vm install --yes --force \
  --image 'dockurr/windows@sha256:REPLACE_WITH_DIGEST'
```

Or:

```bash
export ATELIER_WINDOWS_IMAGE='dockurr/windows@sha256:…'
atelier-windows-vm install --yes --force
```

You can also edit `image:` in `~/.config/atelier/windows/docker-compose.yml` and run `atelier-windows-vm stop` then `launch`.

---

## 8. Daily use (FreeRDP)

```bash
atelier-windows-vm launch      # full-screen RDP; stops VM when session ends
atelier-windows-vm launch -k   # keep VM running after RDP closes
atelier-windows-vm stop
atelier-windows-vm status
```

Or open **Windows** from Rofi (`Super+d`).

### First launch while Windows still installing

If readiness times out (~2 minutes), the container **stays up**. Use `http://127.0.0.1:8006`, wait, then `launch` again.

### Rofi appears to do nothing

```bash
cat "${XDG_RUNTIME_DIR:-/tmp}/atelier-windows-vm-last-error.txt"
atelier-windows-vm launch   # from a terminal
```

### Microsoft account / password mismatch

If you switch the guest to a Microsoft account, the compose password may no longer match FreeRDP auto-login. Edit `USERNAME` / `PASSWORD` in the compose file (keep double quotes) or change the local password inside Windows.

---

## 9. Shared files

Host: **`~/Atelier/Windows`**  
Guest: dockur shared mount (Shared / `/shared`).

Only this directory is exposed. Treat contents as untrusted both ways.

---

## 10. Paths

| Role | Path |
|------|------|
| Compose + credentials | `~/.config/atelier/windows/docker-compose.yml` |
| Virtual disk / storage | `~/.local/share/atelier/windows` |
| Shared folder | `~/Atelier/Windows` |
| Last GUI error | `$XDG_RUNTIME_DIR/atelier-windows-vm-last-error.txt` (or under `/tmp`) |
| Example compose | `/usr/share/atelier/windows/docker-compose.yml.example` |
| Offline short help | `/usr/share/doc/atelier/windows-vm-README.txt` |

---

## 11. Remove

```bash
atelier-windows-vm remove           # dialog confirm (default No)
atelier-windows-vm remove --yes     # scripted
```

Deletes compose + VM disk. **Keeps** `~/Atelier/Windows`.  
Does not uninstall the XBPS package (`sudo xbps-remove atelier-windows-vm`).

---

## 12. Optional keybind

No default sxhkd bind. Example user snippet:

```
# ~/.config/sxhkd/sxhkdrc
super + shift + w
    atelier-windows-vm launch
```

---

## 13. Troubleshooting

| Symptom | What to try |
|---------|-------------|
| No `/dev/kvm` | Enable VT-x/AMD-V; `modprobe kvm-intel` or `kvm-amd`; not WSL2 |
| `docker info` fails | `sudo atelier-setup-docker`; re-login |
| Ports busy | `ss -lntp \| grep -E '8006\|3389'`; stop other VMs |
| RDP connects too early | Wait for web UI; re-`launch` after “windows started successfully” |
| Blank/slow graphics | Launch retries without `/gfx:AVC444` on quick failure |
| Password in `ps` | Prefer `/from-stdin` path (default with `xfreerdp3`); avoid old fallback |

Build/packaging notes: [../build/windows-vm.md](../build/windows-vm.md).

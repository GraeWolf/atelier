# Windows VM (optional)

Status: **optional package available** (install + FreeRDP launch). Requires KVM and Docker.

Atelier offers an opt-in Windows 11 guest for Office-class apps via Docker + FreeRDP. It is **not** part of the default desktop (`atelier-desktop`).

## Setup (available now)

```bash
sudo xbps-install -Sy atelier-windows-vm
sudo atelier-setup-docker
# log out and back in (docker group)
docker info
docker compose version   # or: docker-compose version
```

## Install the guest

Requires an interactive terminal (dialog wizard), KVM, and working Docker:

```bash
atelier-windows-vm install
# open http://127.0.0.1:8006 for install progress
atelier-windows-vm status
atelier-windows-vm stop
```

`remove` deletes compose + VM disk but **keeps** `~/Atelier/Windows`.

## Launch via FreeRDP

```bash
atelier-windows-vm launch      # full-screen RDP; stops VM when you close the session
atelier-windows-vm launch -k   # keep the VM running after RDP closes
```

Or open **Windows** from Rofi (`Super+d`).

First boot can take a long time while Windows installs; use `http://127.0.0.1:8006` and re-run `launch` after it finishes.

If Rofi seems to do nothing, check:

```bash
cat "${XDG_RUNTIME_DIR:-/tmp}/atelier-windows-vm-last-error.txt"
atelier-windows-vm launch   # from a terminal for full messages
```

## Limits (by design)

- No GPU passthrough (not for gaming or heavy video editing)
- Only `~/Atelier/Windows` is shared with the guest
- Requires KVM (`/dev/kvm`) — typically bare metal, not WSL2
- Windows 11 is unactivated; you bring your own license

## Security (read before using)

- Membership in the **docker** group is roughly equivalent to **root** on the machine
- Shared folder is a **two-way** exchange; treat it as untrusted
- Compose file under `~/.config/atelier/windows/` holds credentials (mode 0600 when generated)

Build/policy notes: [../build/windows-vm.md](../build/windows-vm.md).

## Troubleshooting (future)

If the Rofi “Windows” entry does nothing, check:

```text
${XDG_RUNTIME_DIR:-/tmp}/atelier-windows-vm-last-error.txt
```

or run `atelier-windows-vm launch` from a terminal.

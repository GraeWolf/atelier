# Windows VM (optional)

Status: **optional package under development**. Full install/launch UX is not finished yet.

When complete, Atelier will offer an opt-in Windows 11 guest for Office-class apps via Docker + FreeRDP. It is **not** part of the default desktop (`atelier-desktop`).

## Planned flow

```bash
sudo xbps-install -Sy atelier-windows-vm
sudo atelier-setup-docker
# log out and back in (docker group)
atelier-windows-vm install
atelier-windows-vm launch
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

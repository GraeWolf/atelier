# Graphical installer

Custom **simple** GUI installer for Atelier (not Calamares).

## MVP scope

| Supported | Not supported |
|-----------|----------------|
| Whole-disk erase & install | Encryption |
| EFI (GPT+ESP) and BIOS (GPT+bios_grub) | Custom partition layouts |
| Hostname, user, root password | Dual-boot / preserve foreign OS |
| Timezone, locale, keymap (text entry) | RAID/LVM |
| base-system + atelier-desktop + GRUB | Automatic mirror ranking |
| Personal repo when present on live media | |

## Components

| Path | Role |
|------|------|
| `atelier-install` | Main installer script (yad → zenity → dialog) |
| `atelier-install.desktop` | Live desktop launcher entry |

Packaged as **`atelier-installer`** in the personal XBPS repo (`packages/atelier-installer/`).

## Live usage

1. Boot the live ISO (graphical session)
2. Run **Install Atelier Linux** from the menu, or:

```bash
atelier-install
# or
sudo atelier-install
```

3. Confirm disk wipe, answer prompts, wait for package download/install
4. Reboot into the installed system

Log: `/tmp/atelier-install.log`

## Dependencies (runtime)

- `yad` (preferred) or `zenity` or `dialog`
- `parted`, `e2fsprogs`, `dosfstools` (EFI), `util-linux`
- `xbps`, `grub` / `grub-x86_64-efi`, `sudo`, `polkit` (for pkexec)

## Design notes

- Prefer clarity over cleverness; heavy logic is sequential shell
- Re-execs via `pkexec` / `sudo` when not root
- Copies live personal repo to `/usr/share/atelier/repo` on the target
- Removes live-only files (`atelier-live.sh`, `void-installer`) from the target

## Temporary fallback

The live image may still embed **void-installer** (text UI) as a fallback. Prefer `atelier-install` for the guided path.

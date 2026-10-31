# Installer

Atelier whole-disk installer: **TUI by default** (`dialog`), optional GUI (`--gui`).

## Scope

| Supported | Not supported |
|-----------|----------------|
| Whole-disk erase & install | Custom partition layouts |
| Optional LUKS2 on root (unencrypted `/boot`) | Encrypted `/boot` / GRUB cryptodisk |
| Optional `/swapfile` for hibernation (default off) | Swap *partition* / LVM |
| EFI (GPT+ESP) and BIOS (GPT+bios_grub) | Dual-boot / preserve foreign OS |
| Hostname, user, locked root, sudo via wheel | RAID |
| Timezone, locale, keymap (preset; editable from the summary) | — |
| base-system + atelier-desktop + GRUB | Automatic dual-GPU polish |
| Preset package list (`dropbox` on the desktop preset) + xdg-user-dirs | |
| gnome-keyring PAM unlock at TTY login | |
| Personal repo when present on live media | |
| Optional proprietary NVIDIA; XLibre always (no X.Org fallback) | Shipping full nvidia.ko on default live ISO |

## Components

| Path | Role |
|------|------|
| `atelier-install` | Main installer (default **dialog** TUI; `--gui` for yad) |
| `atelier-install.desktop` | Desktop launcher (`--gui`) when a session is running |

Packaged as **`atelier-installer`** in the personal XBPS repo (`packages/atelier-installer/`).

## Live usage

1. Boot the live ISO to a **TTY**
2. Log in as **anon** / **voidlinux**
3. Run:

```bash
sudo atelier-install          # TUI (dialog)
sudo atelier-install --gui    # after startx, optional
```

3. Confirm the disk, enter a hostname and username (skipped when your own preset sets them), set the user password (root stays locked; that user has sudo), enter a LUKS passphrase only if encryption is on, then Install or Edit. Wait for package download/install
4. Reboot into the installed system (enter the LUKS passphrase at boot if you encrypted)

Log: `/tmp/atelier-install.log`

## Dependencies (runtime)

- `dialog` (default TUI); `yad` / `zenity` optional for `--gui`
- `parted`, `e2fsprogs`, `dosfstools` (EFI), `util-linux`, `cryptsetup` (optional LUKS2)
- `xbps`, `grub` / `grub-x86_64-efi`, `sudo`, `polkit` (for pkexec)

## Design notes

- Prefer clarity over cleverness; heavy logic is sequential shell
- Re-execs via `pkexec` / `sudo` when not root
- Copies live personal repo to `/usr/share/atelier/repo` on the target
- Removes live-only files (`atelier-live.sh`, `void-installer`) from the target

## Temporary fallback

The live image may still embed **void-installer** (text UI) as a fallback. Prefer `atelier-install` for the guided path.

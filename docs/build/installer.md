# Atelier graphical installer (build notes)

## Package

| Item | Value |
|------|--------|
| Source | `installer/atelier-install` |
| XBPS package | `atelier-installer` **0.4.0+** |
| Sync | `scripts/sync-atelier-installer-files.sh` |
| Desktop entry | `/usr/share/applications/atelier-install.desktop` |

```bash
./scripts/build-repo.sh
xbps-query --repository=$PWD/repo/out -R atelier-installer
```

Live images include `atelier-installer` via `iso/package-lists/live.txt`.

## Modes (v0.4)

| Command | UI |
|---------|-----|
| `atelier-install` | **TUI** (`dialog`) — default, for live tty |
| `atelier-install --tui` | Force dialog |
| `atelier-install --gui` | yad/zenity when DISPLAY is set |

Stateful Back/Next flow (whole-disk only):

welcome → disk → encryption → identity → locale → graphics → software → mirror → bootloader → summary → install

### UI rules

- **Default dialog (TUI)**; optional GUI with `--gui`
- **ASCII-only** UI strings
- Explicit **Yes/No** or **Back/Next/Abort**
- dialog: `--stdout` + keys from `/dev/tty` (prevents raw `^[[A`/`^[[B` arrow garbage)
- Wizard pages: real Next/Back/Abort buttons (`--yesno` + `--extra-button`), not a tag menu
- `ensure_gui_env` + sudo/pkexec preserve `TERM` (ncurses needs it on a live TTY)

### Options wired into install phase

| Variable | Effect |
|----------|--------|
| `VOID_REPO` / `VOID_NONFREE_REPO` | xbps repos; **nonfree always** (Dropbox) |
| `INSTALL_NVIDIA` | nvidia + atelier-nvidia |
| `INSTALL_XLIBRE` | atelier-xlibre-repo + xlibre |
| `PKG_EXTRA_CLI` / `PKG_MEDIA` | optional packages if in Void |
| `INSTALL_BOOTLOADER` | GRUB install or skip |
| `ENCRYPT_DISK` | LUKS2 on root; unencrypted `/boot`; `cryptsetup` on target |
| (always) | `dropbox`, `xdg-user-dirs`, `xdg-user-dirs-gtk` |

After `useradd`, runs `su - $USER -c xdg-user-dirs-update`.

## Optional LUKS2

Opt-in (`ENCRYPT_DISK=0` by default). No LVM, no GRUB cryptodisk, no swap.

| Firmware | Encrypted layout |
|----------|------------------|
| EFI | ESP 512MiB `/boot/efi`; 1GiB ext4 `/boot`; LUKS2 → ext4 `/` |
| BIOS | 1MiB bios_grub; 1GiB ext4 `/boot`; LUKS2 → ext4 `/` |

Unencrypted layout is unchanged (no dedicated `/boot`).

Mapper: `/dev/mapper/cryptroot`.

| File | Role |
|------|------|
| `/etc/crypttab` | `cryptroot UUID=<LUKS-UUID> none luks` (container UUID) |
| `/etc/fstab` | root UUID is the **inner ext4** on the mapper |
| `/etc/dracut.conf.d/10-atelier-crypt.conf` | `crypt` module + install crypttab |
| `/etc/default/grub` | `rd.luks.uuid=<LUKS-UUID> rd.luks.name=<UUID>=cryptroot` |

Initramfs is regenerated **after** those files exist (`dracut --force --regenerate-all`). Passphrase is written to a 0600 temp keyfile for `cryptsetup`, never logged.

## Runtime dependencies

dialog (TUI), yad (optional GUI), parted, e2fsprogs, dosfstools, util-linux, cryptsetup, xbps, grub*, sudo, polkit

## Testing checklist

- [ ] Back from mid-wizard restores previous step without losing earlier answers (re-entry may re-prompt; state kept in shell vars)
- [ ] Non-NVIDIA VM: no NVIDIA packages
- [ ] Mirror appears in target `00-repository-main.conf`
- [ ] Bootloader skip leaves system without GRUB step
- [ ] Optional groups install only when checked
- [ ] Encryption default No keeps the 2-partition (EFI) / 2-partition (BIOS) layout
- [ ] Encryption Yes: LUKS2 on p3, ext4 `/boot` on p2, passphrase at dracut, `/boot` not LUKS
- [ ] `rd.luks.uuid` and crypttab UUID match the LUKS container (not the inner ext4)

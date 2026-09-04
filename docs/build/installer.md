# Atelier graphical installer (build notes)

## Package

| Item | Value |
|------|--------|
| Source | `installer/atelier-install` |
| XBPS package | `atelier-installer` **0.5.3+** |
| Sync | `scripts/sync-atelier-installer-files.sh` |
| Desktop entry | `/usr/share/applications/atelier-install.desktop` |

```bash
./scripts/build-repo.sh
xbps-query --repository=$PWD/repo/out -R atelier-installer
```

Live images include `atelier-installer` via `iso/package-lists/live.txt`.

## Modes (v0.5+)

| Command | UI |
|---------|-----|
| `atelier-install` | **TUI** (`dialog`) — default, for live tty |
| `atelier-install --tui` | Force dialog |
| `atelier-install --gui` | yad/zenity when DISPLAY is set |

Stateful Back/Next flow (whole-disk only):

welcome → disk → encryption → swap → identity → locale → graphics → software → mirror → bootloader → summary → install

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
| `INSTALL_NVIDIA` | separate transaction: linux-headers + nvidia + atelier-nvidia (failure is non-fatal) |
| `INSTALL_XLIBRE` | atelier-xlibre-repo + xlibre |
| `PKG_EXTRA_CLI` / `PKG_MEDIA` | optional packages if in Void |
| `INSTALL_BOOTLOADER` | GRUB install or skip |
| `ENCRYPT_DISK` | LUKS2 on root; unencrypted `/boot`; `cryptsetup` on target |
| `CREATE_SWAP` | `/swapfile` (RAM rounded up) + `resume=` / `resume_offset` + dracut `resume` |
| (always) | `dropbox`, `xdg-user-dirs`, `xdg-user-dirs-gtk` |

After `useradd`, runs `su - $USER -c xdg-user-dirs-update`, then `atelier-setup-keyring` so TTY login unlocks gnome-keyring.

The live log `/tmp/atelier-install.log` is copied to the target as
`/var/log/atelier-install.log` before unmount (including failed installs
when the target is still mounted).

## Optional LUKS2

Opt-in (`ENCRYPT_DISK=0` by default). No LVM, no GRUB cryptodisk, no swap *partition*.
Optional `/swapfile` for hibernation is a separate wizard step (`CREATE_SWAP=0` by default);
the file sits on encrypted root when LUKS is enabled.

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
| `/etc/dracut.conf.d/10-atelier-crypt.conf` | `crypt` module + crypttab; USB HID `force_drivers`; `omit_drivers hid_asus` (N-KEY stays on hid-generic at the passphrase prompt) |
| `/etc/default/grub` | `rd.luks.uuid=<LUKS-UUID> rd.luks.name=<UUID>=cryptroot` |

Initramfs is regenerated **after** those files exist (`dracut --force --regenerate-all`). Passphrase is written to a 0600 temp keyfile for `cryptsetup`, never logged.

## Optional swapfile (hibernation)

Opt-in (`CREATE_SWAP=0` by default). No extra partition. File is `/swapfile` on root (ext4), size = `MemTotal` rounded up to the next GiB.

| File | Role |
|------|------|
| `/swapfile` | `mkswap --file`; mode 600 |
| `/etc/fstab` | `/swapfile none swap sw 0 0` |
| `/etc/dracut.conf.d/20-atelier-resume.conf` | `resume` module (must be explicit in the installer chroot) |
| `/etc/default/grub` | `resume=UUID=<root ext4 UUID> resume_offset=<filefrag>` |

`resume=` is the **inner ext4** UUID (same as `root=`), never the LUKS container. Existing systems: `sudo atelier-setup-swap`. Helper lives in `atelier-config`.

elogind drop-ins (`HibernateDelaySec=30min`, lid `suspend-then-hibernate`) are written with the swapfile so sleep automatically hibernates after 30 minutes.

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
- [ ] Encryption Yes: initramfs includes `usbhid`/`hid-generic` and omits `hid_asus` (ROG N-KEY types at the passphrase prompt)
- [ ] `rd.luks.uuid` and crypttab UUID match the LUKS container (not the inner ext4)
- [ ] Swap default No: no `/swapfile`, no `resume=` on GRUB
- [ ] Swap Yes: `/swapfile` in fstab, `resume=UUID=<root ext4>` + `resume_offset`, dracut resume module
- [ ] Swap + LUKS: `rd.luks.*` kept; `resume=` is the inner ext4 UUID
- [ ] `atelier-setup-swap --yes` is idempotent (no duplicate fstab/GRUB tokens)

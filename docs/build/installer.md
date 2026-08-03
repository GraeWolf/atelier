# Atelier graphical installer (build notes)

## Package

| Item | Value |
|------|--------|
| Source | `installer/atelier-install` |
| XBPS package | `atelier-installer` |
| Sync | `scripts/sync-atelier-installer-files.sh` |
| Desktop entry | `/usr/share/applications/atelier-install.desktop` |

Build with the personal repo:

```bash
./scripts/build-repo.sh
xbps-query --repository=$PWD/repo/out -R atelier-installer
```

Live images include `atelier-installer` via `iso/package-lists/live.txt`.

## Runtime stack

- GUI: **yad** (preferred), else zenity, else dialog
- Storage: parted, mkfs.ext4, mkfs.vfat (EFI)
- Privilege: re-exec with **pkexec** or **sudo**

## Install algorithm (summary)

1. Collect disk + identity via GUI
2. `wipefs` + `parted` GPT layout
3. Format and mount under `/mnt/atelier-target` (bind dev/proc/sys/run)
4. `xbps-install -r` from Void mirror + live personal repo
5. Configure hostname, locale, timezone, users, services, fstab
6. `grub-install` + `grub-mkconfig`
7. Unmount; offer reboot

## Limitations (document for users)

See `docs/user/installer.md` and `installer/README.md`.

## Testing checklist

- [ ] `./scripts/build-repo.sh` produces `atelier-installer`
- [ ] Live ISO includes package and menu entry
- [ ] VM install (EFI) completes and reboots to bspwm
- [ ] BIOS VM path (if available) completes
- [ ] Target has `/usr/share/atelier/repo` and can query atelier packages
- [ ] Live-only files absent on target (`atelier-live.sh`, void-installer)

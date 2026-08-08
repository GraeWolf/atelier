# Atelier graphical installer (build notes)

## Package

| Item | Value |
|------|--------|
| Source | `installer/atelier-install` |
| XBPS package | `atelier-installer` **0.2.0+** |
| Sync | `scripts/sync-atelier-installer-files.sh` |
| Desktop entry | `/usr/share/applications/atelier-install.desktop` |

```bash
./scripts/build-repo.sh
xbps-query --repository=$PWD/repo/out -R atelier-installer
```

Live images include `atelier-installer` via `iso/package-lists/live.txt`.

## Wizard (v0.2)

Stateful Back/Next flow (whole-disk only):

welcome → disk → identity → locale → graphics → software → mirror → bootloader → summary → install

### UI rules

- **yad** preferred; zenity/dialog fallbacks
- **ASCII-only** dialog strings (yad + C locale safety)
- Explicit **Yes/No** or **Back/Next/Abort** exit codes
- `ensure_gui_env` + pkexec env preservation (`DISPLAY`, `LANG`, `XDG_RUNTIME_DIR`, …)

### Options wired into install phase

| Variable | Effect |
|----------|--------|
| `VOID_REPO` / `VOID_NONFREE_REPO` | xbps repos for install + target `/etc/xbps.d` |
| `INSTALL_NVIDIA` | nonfree + nvidia + atelier-nvidia |
| `INSTALL_XLIBRE` | atelier-xlibre-repo + xlibre |
| `PKG_EXTRA_CLI` / `PKG_MEDIA` | optional packages if in Void |
| `INSTALL_BOOTLOADER` | GRUB install or skip |

## Runtime dependencies

yad (or zenity/dialog), parted, e2fsprogs, dosfstools, util-linux, xbps, grub*, sudo, polkit

## Testing checklist

- [ ] Back from mid-wizard restores previous step without losing earlier answers (re-entry may re-prompt; state kept in shell vars)
- [ ] Non-NVIDIA VM: no NVIDIA packages
- [ ] Mirror appears in target `00-repository-main.conf`
- [ ] Bootloader skip leaves system without GRUB step
- [ ] Optional groups install only when checked

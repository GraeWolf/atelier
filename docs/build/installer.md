# Atelier graphical installer (build notes)

## Package

| Item | Value |
|------|--------|
| Source | `installer/atelier-install` |
| XBPS package | `atelier-installer` **0.3.0+** |
| Sync | `scripts/sync-atelier-installer-files.sh` |
| Desktop entry | `/usr/share/applications/atelier-install.desktop` |

```bash
./scripts/build-repo.sh
xbps-query --repository=$PWD/repo/out -R atelier-installer
```

Live images include `atelier-installer` via `iso/package-lists/live.txt`.

## Modes (v0.3)

| Command | UI |
|---------|-----|
| `atelier-install` | **TUI** (`dialog`) — default, for live tty |
| `atelier-install --tui` | Force dialog |
| `atelier-install --gui` | yad/zenity when DISPLAY is set |

Stateful Back/Next flow (whole-disk only):

welcome → disk → identity → locale → graphics → software → mirror → bootloader → summary → install

### UI rules

- **Default dialog (TUI)**; optional GUI with `--gui`
- **ASCII-only** UI strings
- Explicit **Yes/No** or **Back/Next/Abort**
- `ensure_gui_env` + pkexec env preservation

### Options wired into install phase

| Variable | Effect |
|----------|--------|
| `VOID_REPO` / `VOID_NONFREE_REPO` | xbps repos; **nonfree always** (Dropbox) |
| `INSTALL_NVIDIA` | nvidia + atelier-nvidia |
| `INSTALL_XLIBRE` | atelier-xlibre-repo + xlibre |
| `PKG_EXTRA_CLI` / `PKG_MEDIA` | optional packages if in Void |
| `INSTALL_BOOTLOADER` | GRUB install or skip |
| (always) | `dropbox`, `xdg-user-dirs`, `xdg-user-dirs-gtk` |

After `useradd`, runs `su - $USER -c xdg-user-dirs-update`.

## Runtime dependencies

dialog (TUI), yad (optional GUI), parted, e2fsprogs, dosfstools, util-linux, xbps, grub*, sudo, polkit

## Testing checklist

- [ ] Back from mid-wizard restores previous step without losing earlier answers (re-entry may re-prompt; state kept in shell vars)
- [ ] Non-NVIDIA VM: no NVIDIA packages
- [ ] Mirror appears in target `00-repository-main.conf`
- [ ] Bootloader skip leaves system without GRUB step
- [ ] Optional groups install only when checked

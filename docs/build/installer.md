# Atelier dialog installer (build notes)

## Package

| Item | Value |
|------|--------|
| Source | `installer/atelier-install` |
| XBPS package | `atelier-installer` **0.5.12** |
| Sync | `scripts/sync-atelier-installer-files.sh` |
| Preset | `/etc/atelier/install.conf` |

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
| `atelier-install --text` | Plain prompts on stdin/stderr |
| `atelier-install --preset FILE` | Load settings from FILE |
| `atelier-install --dry-run` | Stop after the summary; do not partition |

The live ISO installs `/etc/atelier/install.conf` from this package (source: `installer/install.conf`). That file is the desktop preset: `America/New_York`, `en_US.UTF-8`, keymap `us`, the default Void mirror, NVIDIA `auto`, encryption off, swapfile off, GRUB on, Steam on (`GAMING=yes`), and extra package `dropbox`. `HOSTNAME` and `USERNAME` are empty in that file, so the wizard asks. A private `--preset` file may set them, and a value set there is not asked. Built-in defaults match the shipped file when it is absent. Omitting `GAMING` keeps the built-in default, which is yes.

Flow (whole-disk only):

welcome → disk (select + confirm) → hostname and username, unless the preset set them → user password → LUKS passphrase only if encryption is on → summary

The summary is one dialog menu: **Start installation / Edit a field / Quit**, with the chosen settings in the prompt. The prompt is nine lines so it fits a 24-row console and Quit stays on screen. The full summary text is longer than that box: dialog exits immediately (`Can't make sub-window`) and the choice is never captured. Twelve lines still draws, but the menu scrolls and Quit is hidden. Escape or Cancel redisplays that menu. It does not start the install and it does not open an error box. Edit can change disk, hostname, username, password, timezone, locale, keymap, mirror, NVIDIA, Steam, encryption, swapfile, GRUB, and the extra package list. Mirror and GRUB are preset-only; they are not their own wizard pages.

Root is locked. The user is in the `wheel` group and `/etc/sudoers.d/wheel` grants sudo. The summary says so. There is one user password (entered twice to confirm). The LUKS passphrase is separate and is not stored in the preset.

### UI rules

- **dialog TUI** only. There is no graphical front end
- **ASCII-only** UI strings
- Explicit **Yes/No** or **Back/Next/Abort**. Escape on a Yes/No screen is not No; the question is shown again
- dialog: `--stdout` + keys from `/dev/tty` (prevents raw `^[[A`/`^[[B` arrow garbage)
- Wizard pages: real Next/Back/Abort buttons (`--yesno` + `--extra-button`), not a tag menu
- `ensure_locale` + sudo/pkexec preserve `TERM` (ncurses needs it on a live TTY)

### Options wired into install phase

| Variable | Effect |
|----------|--------|
| `VOID_REPO` / `VOID_NONFREE_REPO` | xbps repos from the preset mirror. Nonfree is still configured. `dropbox` is installed only when listed in preset `PACKAGES` |
| `INSTALL_NVIDIA` | `NVIDIA=auto` (default) installs proprietary drivers only when a GPU is detected. `yes` / `no` force it. Separate transaction: linux-headers + nvidia + atelier-nvidia (failure is non-fatal, shown on the result screen; `xbps-reconfigure -a` failure is shown too) |
| `INSTALL_GAMING` | `GAMING=yes` (shipped preset and built-in default) or `no`. Separate transactions: `void-repo-multilib` + `void-repo-multilib-nonfree`, then Steam and the 32-bit stack from `installer/gaming.txt`, then `nvidia-libs-32bit` only when NVIDIA packages are actually installed. Failure is non-fatal and is named on the result screen. Steam is not a dependency of `atelier-desktop` |
| `INSTALL_XLIBRE` | always `1`. `atelier-xlibre-repo` + `xlibre` + `xlibre-xserver`. No X.Org fallback. Missing repo, failed install, or no `/usr/bin/Xorg` aborts the install |
| `PKG_EXTRA` | preset `PACKAGES` (the shipped file lists `dropbox`) |
| `INSTALL_BOOTLOADER` | preset `GRUB` (default yes) |
| `ENCRYPT_DISK` | preset `ENCRYPT` (default no). LUKS2 on root; unencrypted `/boot`; `cryptsetup` on target |
| `CREATE_SWAP` | preset `SWAP` (default no). `/swapfile` (RAM rounded up) + `resume=` / `resume_offset` + dracut `resume` |
| (always) | `xdg-user-dirs`, `xdg-user-dirs-gtk`, `void-repo-nonfree` |

After `useradd`, runs `su - $USER -c xdg-user-dirs-update`, then `atelier-setup-keyring` so TTY login unlocks gnome-keyring.

The live log `/tmp/atelier-install.log` is copied to the target as
`/var/log/atelier-install.log` before unmount (including failed installs
when the target is still mounted).

## Preflight (before the disk is wiped)

After the summary is confirmed, and before `parted` / `wipefs`, the installer checks:

| Check | Failure |
|-------|---------|
| Tools (`parted`, `mkfs.ext4`, `xbps-install`, `xbps-query`, `lsblk`, `blkid`, `mount`, `umount`, `wipefs`; `mkfs.vfat` on UEFI; `cryptsetup` / `mkswap` when those options are on) | Stop. Disk unchanged |
| Firmware (`/sys/firmware` → UEFI or BIOS) | Stop if `/sys/firmware` is missing |
| NVIDIA GPU (`lspci` or `/sys/bus/pci`) | Stop if the PCI bus cannot be inspected. No GPU is a successful detection, not an error |
| Network to the chosen mirror's `x86_64-repodata` | Stop. "Network unreachable" vs "mirror index" are separate messages |
| Personal repo (`atelier-desktop`, `atelier-xlibre-repo`) | Stop |
| Void main (`base-system`, `linux`), each preset package (shipped preset: `dropbox` from nonfree), and `nvidia` / `linux-headers` when NVIDIA will be installed | Stop |
| Gaming, when `GAMING=yes`: `void-repo-multilib` and `void-repo-multilib-nonfree` on the main mirror, each package in `installer/gaming.txt`, and `nvidia-libs-32bit` on `…/multilib/nonfree` when NVIDIA will be installed. `xbps-query -M` fetches the remote index (same as the XLibre check). 32-bit names are queried on `…/multilib` | Stop. The disk is not modified |
| XLibre repo (`xlibre`, `xlibre-xserver`) via `xbps-query -M` so the GitHub index is actually fetched. A plain `xbps-query -R` only reads a previously synced cache, which the live ISO has for Void but not for XLibre | Stop. No X.Org fallback |

## Failures during install

The script uses `set -eEuo pipefail`. `set -E` is required: without errtrace, an `ERR` trap is not inherited by functions, so a failure inside `partition_disk` or `install_packages` exits 1 with no error screen, no unmount, and no LUKS close.

On failure the installer logs the phase (`preflight`, `partitioning`, `mounting`, `packages`, `configure`, `bootloader`), shows that phase plus the last lines of the log, copies the log onto the target when it is still mounted, unmounts, and closes the LUKS mapper.

XLibre install failure aborts the install. NVIDIA install failure does not roll back the desktop; `xbps-reconfigure -a` is not ignored, and either failure is named on the result screen.

Steam is the same kind of failure as NVIDIA, not the same kind as XLibre. The desktop does not need Steam to boot, and there is no second display server to fall back to if XLibre is missing. Preflight already refuses to wipe the disk when the multilib packages cannot be seen, so a later Steam failure is a surprise (mirror drop, dependency conflict, NVIDIA libs skipped because the driver transaction failed). That transaction is separate. The result screen says Steam was not installed, or that Steam installed but `nvidia-libs-32bit` did not, and it prints the `xbps-install` command to retry. The base system stays.

## Gaming packages

The list is `installer/gaming.txt`, installed as `/usr/share/atelier/installer/gaming.txt`. It is not under `iso/package-lists/` (those lists are the live image) and it is not an `atelier-gaming` metapackage.

A metapackage would record the names, but Void cannot enable `void-repo-multilib` and install from that repo in one transaction: the new index is visible only after the repo package is configured. `nvidia-libs-32bit` is also conditional. The installer therefore does three transactions when gaming and NVIDIA are both on: repo enablers, Steam plus the common 32-bit stack, then `nvidia-libs-32bit` if `nvidia` is actually installed. It writes `/etc/xbps.d/30-repository-multilib.conf` and `31-repository-multilib-nonfree.conf` for the chosen mirror. `void-repo-multilib` still drops its own file pointing at `repo-default`, which is the same pattern as `void-repo-nonfree`.

Names were checked against `https://repo-default.voidlinux.org/current` on 2026-10-31. There is no `libgl-32bit` package; `libglvnd-32bit` provides 32-bit libGL. The client package is nonfree `steam` (`1.0.0.87_1`), not multilib's `steam-32bit`. `nvidia-libs-32bit` and `nvidia` were both `595.112.07_1`. `libgcc-32bit`, `libstdc++-32bit`, `libdrm-32bit`, and `libva-32bit` are included because Void's Steam README lists them as the generic 32-bit runtime and the `steam` package does not depend on them.

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

dialog (TUI), parted, e2fsprogs, dosfstools, util-linux, cryptsetup, xbps, grub*, sudo, polkit (pkexec when the installer is not already root)

## Testing checklist

- [ ] Back from mid-wizard restores previous step without losing earlier answers (re-entry may re-prompt; state kept in shell vars)
- [ ] Non-NVIDIA VM: no NVIDIA packages
- [ ] Mirror appears in target `00-repository-main.conf`
- [ ] Bootloader skip leaves system without GRUB step
- [ ] Preset `PACKAGES` are the only extra packages (`dropbox` when the shipped preset is used; clearing `PACKAGES` skips it)
- [ ] Welcome screen says v0.5.12 and names the preset file
- [ ] Summary shows Gaming. Edit → Steam toggles it, and the summary line changes. On an 80x24 console the menu still shows Start installation, Edit a field, and Quit
- [ ] `GAMING=yes` with the network up: preflight log shows multilib packages found via `xbps-query -M` before the disk is partitioned. `GAMING=no` does not query them
- [ ] Installed system with gaming on has `steam`, `mesa-dri-32bit`, `vulkan-loader-32bit`, `libglvnd-32bit`, and (when NVIDIA installed) `nvidia-libs-32bit`. `xbps-query -l | grep 32bit` shows them
- [ ] A Steam transaction failure is named on the result screen and the desktop install is still there
- [ ] Shipped preset asks for hostname and username (invalid names are re-asked). A private preset that sets them skips those questions. Both stay on Edit
- [ ] Summary menu shows Start installation / Edit a field / Quit. Escape returns to that menu. OK on each choice does that action
- [ ] Root cannot log in; the created user is in `wheel` and sudo works
- [ ] A username such as `Kevin` is rejected and re-asked (it is not stored as `evin`)
- [ ] Timezone choices include `America/New_York`, `Pacific/*`, and `US/*` when those names exist in tzdata
- [ ] Escape or a blank line on a Yes/No question does not select No
- [ ] `ENCRYPT=no` does not ask for a LUKS passphrase; `ENCRYPT=yes` does, before the summary
- [ ] Encryption default No keeps the 2-partition (EFI) / 2-partition (BIOS) layout
- [ ] Encryption Yes: LUKS2 on p3, ext4 `/boot` on p2, passphrase at dracut, `/boot` not LUKS
- [ ] Encryption Yes: initramfs includes `usbhid`/`hid-generic` and omits `hid_asus` (ROG N-KEY types at the passphrase prompt)
- [ ] `rd.luks.uuid` and crypttab UUID match the LUKS container (not the inner ext4)
- [ ] Swap default No: no `/swapfile`, no `resume=` on GRUB
- [ ] Swap Yes: `/swapfile` in fstab, `resume=UUID=<root ext4>` + `resume_offset`, dracut resume module
- [ ] Swap + LUKS: `rd.luks.*` kept; `resume=` is the inner ext4 UUID
- [ ] `atelier-setup-swap --yes` is idempotent (no duplicate fstab/GRUB tokens)
- [ ] Preflight failure (offline, bad mirror, missing personal repo, missing XLibre repo) stops before the disk is partitioned
- [ ] With the network up, preflight trusts the XLibre key and the log shows `found xlibre-…` and `found xlibre-xserver-…` from the GitHub index (not only the installed `atelier-xlibre-repo` package)
- [ ] A command failure inside an install function shows the phase and the log tail, then unmounts and closes LUKS
- [ ] Installed system has `xlibre-xserver` and `/usr/bin/Xorg` (or `/usr/bin/X`); no X.Org-only install
- [ ] NVIDIA package or `xbps-reconfigure -a` failure is visible on the result screen

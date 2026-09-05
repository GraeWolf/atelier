# Installing Atelier Linux

## From the live ISO (TTY + TUI)

1. Boot the live medium. You get a **text login** (no automatic desktop).
2. Log in as **anon** / **voidlinux** (void-mklive defaults).
3. Start the installer:

   ```bash
   sudo atelier-install
   ```

   This runs a **dialog** TUI wizard (similar spirit to Void’s installer).

4. Optional GUI installer (if you started a desktop with `startx`):

   ```bash
   sudo atelier-install --gui
   ```

5. Walk **Back / Next** through disk, optional encryption, optional swapfile, identity, locale, graphics, optional software, mirror, bootloader, and summary.
6. Wait for packages (needs network). Log: `/tmp/atelier-install.log` (copied to `/var/log/atelier-install.log` on the new system)
7. Reboot; remove the live medium. On the installed system, log in and run `startx` for the desktop.

Optional on the live medium only:

```bash
startx    # themed bspwm desktop is still on the ISO if you want it
```

## Wizard steps

| Step | What you choose |
|------|-----------------|
| Welcome | Overview |
| Disk | Whole disk to erase |
| Encryption | Optional LUKS2 on root (default: No) |
| Swapfile | Optional `/swapfile` for hibernation (default: No; size = RAM rounded up) |
| Identity | Hostname, user, passwords |
| Locale | Timezone, locale, keymap (lists) |
| Graphics | NVIDIA (if GPU present), Xlibre |
| Software | Optional package groups |
| Mirror | Void package mirror |
| Bootloader | Install GRUB (recommended) or skip |
| Summary | Review and start install |

## What gets installed (always)

- Void base, kernel, NetworkManager, **atelier-desktop** (when personal repo is present)
- **void-repo-nonfree** + **dropbox** (required)
- **xdg-user-dirs** (+ gtk); installer runs `xdg-user-dirs-update` for your user
- **gnome-keyring** PAM unlock at TTY login (`atelier-setup-keyring`)
- GraeWolf void-repo config when present on the live medium

## Disk encryption (optional)

Default is **unencrypted**. If you choose Yes:

- The **root filesystem** is LUKS2 (passphrase at boot, before login).
- `/boot` and the EFI partition stay unencrypted so GRUB can load the kernel.
- There is **no recovery** if you forget the LUKS passphrase.
- The LUKS passphrase is separate from your user and root passwords.
- The initramfs includes USB HID and omits `hid-asus`, so a built-in ASUS ROG N-KEY (Zephyrus) can type the passphrase. `atelier-config` also blacklists `hid-asus` on the real root so the TTY login keeps `hid-generic` (X still sees the keys).

Encrypted layout: EFI System Partition (if EFI) + 1GiB `/boot` + LUKS2 root. No LVM and no swap *partition*.

## Swapfile (optional, hibernation)

Default is **no swap**. If you choose Yes, the installer creates `/swapfile` on root (encrypted if you also chose LUKS), sized to this machine’s RAM rounded up, and sets `resume=` / `resume_offset` so the kernel can hibernate. Suspend then becomes **sleep, then hibernate after 30 minutes** (lid close and the power-menu Suspend action). Immediate Hibernate stays in the power menu.

On an already-installed system:

```bash
sudo atelier-setup-swap
```

Then reboot once so GRUB picks up `resume=`. Hibernate from the power menu (**Super+Ctrl+Escape**). If `loginctl hibernate` says the verb is not supported, run `sudo atelier-setup-swap --status`. Stock kernels disable hibernation under **UEFI Secure Boot** (lockdown); turn Secure Boot off in firmware if you need S4. LUKS installs use `resume=/dev/mapper/cryptroot` so the initramfs unlocks before restoring. See [desktop.md](desktop.md#sleep-verb-hibernate-not-supported).

If resume works for about a minute and then the machine reboots, see [desktop.md](desktop.md#hibernate-resume-then-reboot) (`/var/log/atelier-pm.log`). Do not add kernel parameters until that log points at a cause.

## What it does not do

- Encrypted `/boot` (GRUB cryptodisk)
- Custom partitions / dual-boot
- RAID / LVM / swap *partition*
- Automatic dual-GPU (Optimus) polish

## Graphics

- **NVIDIA GPU detected:** Yes/No for proprietary drivers (separate package transaction; a driver failure does not undo the rest of the install)
- **No NVIDIA (typical VM):** drivers skipped; later: `sudo atelier-setup-nvidia` (always installed with the desktop)
- **Xlibre:** Yes/No (usually No in VMs). With NVIDIA, Atelier uses modesetting + `prime-run` on hybrid laptops.

See [nvidia.md](nvidia.md).

## Fallback

Text UI **void-installer** may still exist on the live image for emergencies.

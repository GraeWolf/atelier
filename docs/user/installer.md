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

5. Walk **Back / Next** through disk, identity, locale, graphics, optional software, mirror, bootloader, and summary.
6. Wait for packages (needs network). Log: `/tmp/atelier-install.log`
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
- GraeWolf void-repo config when present on the live medium

## What it does not do

- Full-disk encryption
- Custom partitions / dual-boot
- Automatic dual-GPU (Optimus) polish

## Graphics

- **NVIDIA GPU detected:** Yes/No for proprietary drivers  
- **No NVIDIA (typical VM):** drivers skipped; later: `sudo atelier-setup-nvidia`  
- **Xlibre:** Yes/No (usually No in VMs)

See [nvidia.md](nvidia.md).

## Fallback

Text UI **void-installer** may still exist on the live image for emergencies.

# Installing Atelier Linux

## From the live ISO

1. Boot the live medium and start the graphical session (`startx` if needed).
2. Run **Install Atelier Linux** from the menu, or:

   ```bash
   atelier-install
   ```

3. Walk the **Back / Next** wizard:

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

4. Wait for packages (needs network). Log: `/tmp/atelier-install.log`
5. Reboot; remove the live medium.

Live user (if needed before install): **anon** / **voidlinux**

## What the installer does

- Erases the **entire** selected disk (GPT: EFI+root or BIOS grub+root)
- Installs Void base, kernel, NetworkManager, **atelier-desktop** when the personal repo is on the medium
- Optional: NVIDIA proprietary, Xlibre, extra CLI/media packages
- Writes chosen Void mirror into the target system
- Creates your user (`wheel`/sudo) and root password

## What it does not do

- Full-disk encryption
- Custom partitions / dual-boot
- Automatic dual-GPU (Optimus) polish

## Graphics

- **NVIDIA GPU detected:** Yes/No for proprietary drivers
- **No NVIDIA (typical VM):** drivers skipped; use `sudo atelier-setup-nvidia` on real hardware later
- **Xlibre:** Yes/No (usually No in VMs)

See [nvidia.md](nvidia.md).

## Optional software groups

- **Extra CLI:** htop, ripgrep, fd, curl, wget (if available in Void)
- **Media:** mpv, ffmpeg

Desktop stack from PLAN is always installed via `atelier-desktop` when present.

## Fallback

Text UI **void-installer** may still exist on the live image for emergencies.

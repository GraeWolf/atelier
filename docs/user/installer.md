# Installing Atelier Linux

## From the live ISO

1. Boot the live medium.
2. Wait for the graphical session (or run `startx` on tty1).
3. Start **Install Atelier Linux** from the application menu, or run:

   ```bash
   atelier-install
   ```

4. Follow the prompts:
   - Confirm you understand the disk will be erased
   - Select the target disk
   - Set hostname, user, passwords, timezone, locale, keymap
   - Optional: proprietary NVIDIA drivers and/or Xlibre
   - Confirm the summary
5. Wait for packages to download and install (needs network).
6. Reboot when finished; remove the live medium.

On NVIDIA desktops you can also run `sudo atelier-setup-nvidia` after install if you skipped the option. See [nvidia.md](nvidia.md).

Log file: `/tmp/atelier-install.log`

## What the MVP installer does

- Erases the **entire** selected disk
- Creates a simple GPT layout (EFI+root or BIOS grub+root)
- Installs Void `base-system`, kernel, GRUB, NetworkManager, and **atelier-desktop** when the personal repository is on the live image
- Creates your user (with `wheel`/sudo) and root password

## What it does not do (yet)

- Full-disk encryption
- Custom partitions or dual-boot
- Automatic mirror selection UI
- NVIDIA proprietary setup (see later docs / Step 6)

## Fallback

Advanced users can still use **void-installer** (text UI) if it is present on the live image.

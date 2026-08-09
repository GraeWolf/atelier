# Quick start

Welcome to **Atelier Linux** — a minimal Void-based system with a themed bspwm desktop (Tokyo Night).

## First boot (installed system)

1. Log in with the user you created during install.
2. If you are on a TTY (text console), start the graphical session:

   ```bash
   startx
   ```

3. You should see bspwm with polybar (Tokyo Night colors).

### Live medium

On the live ISO, autologin may start X for you. If not, log in (default live user is often `anon` / `voidlinux` from void-mklive) and run `startx`.

To install to disk, see [installer.md](installer.md).

## Everyday basics

| Action | How |
|--------|-----|
| Open terminal | **Super+Enter** (ghostty) |
| App launcher | **Super+d** (rofi) |
| Run command | **Super+Shift+d** |
| File manager | **Super+e** (nemo) |
| Lock screen | **Super+Shift+l** |
| Quit session | **Super+Shift+q** |

More bindings: [desktop.md](desktop.md).

## Try these

```bash
fastfetch    # system overview
btop         # processes / resources
eza -la      # modern ls (alias: ls / ll)
```

## NVIDIA desktop

If the display is wrong or you skipped drivers during install:

```bash
sudo atelier-setup-nvidia
sudo reboot
```

Details: [nvidia.md](nvidia.md).

## Customize carefully

Configs live under `~/.config/`. Prefer small edits; see [customization.md](customization.md).

## Browser (Brave Origin)

Atelier enables the **GraeWolf personal Void repo** for packages like `brave-origin`:

```bash
sudo xbps-install -S brave-origin
```

If the repo is missing: `sudo atelier-setup-void-repo` then retry.

## Updates (XBPS)

```bash
sudo xbps-install -Su
```

Atelier packages from the **personal repo** (on the live image or at `/usr/share/atelier/repo` when shipped) can be queried with:

```bash
xbps-query --repository=/usr/share/atelier/repo -Rs atelier
```

## Getting help

| Topic | Doc |
|-------|-----|
| Install from ISO | [installer.md](installer.md) |
| Desktop & keys | [desktop.md](desktop.md) |
| Theming / configs | [customization.md](customization.md) |
| NVIDIA / Xlibre | [nvidia.md](nvidia.md) |
| Building Atelier | [../build/README.md](../build/README.md) |

Project plan and package philosophy: the Git repository `PLAN.md`.

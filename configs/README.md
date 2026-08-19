# Configuration sources

Canonical desktop and theming configuration for Atelier.

These files are the **source of truth**. The `atelier-config` XBPS package installs them into `/etc/skel` (and a few system paths) so new users get a complete Tokyo Night bspwm session.

## Layout

| Path | Installs to | Component |
|------|-------------|-----------|
| `bspwm/bspwmrc` | `~/.config/bspwm/bspwmrc` | Window manager |
| `sxhkd/sxhkdrc` | `~/.config/sxhkd/sxhkdrc` | Hotkeys |
| `polybar/` | `~/.config/polybar/` | Status bar |
| `rofi/` | `~/.config/rofi/` | Launcher |
| `picom/picom.conf` | `~/.config/picom/` | Compositor |
| `ghostty/config` | `~/.config/ghostty/` | Terminal |
| `nvim/` | `~/.config/nvim/` | Neovim (voidwolf-based; Tokyo Night) |
| `keybinds/cheatsheet.txt` | `~/.config/atelier/keybinds.txt` + `/usr/share/doc/atelier/` | Super+k cheat sheet |
| `session/atelier-keybinds` | `/usr/bin/atelier-keybinds` | Floating keybind TUI launcher |
| `session/atelier-screenshot` | `/usr/bin/atelier-screenshot` | Region/window/full capture (clipboard) |
| `session/atelier-power-menu` | `/usr/bin/atelier-power-menu` | Rofi lock/logout/suspend/reboot/off |
| `session/atelier-scratchpad` | `/usr/bin/atelier-scratchpad` | Sticky hidden scratchpad |
| `session/atelier-btop` | `/usr/bin/atelier-btop` | Floating btop launcher |
| `gtk/` | `~/.config/gtk-3.0`, `gtk-4.0` | GTK theme overrides |
| `qt/` | `~/.config/qt5ct`, `qt6ct` | Qt theming via qt5ct/qt6ct |
| `starship/starship.toml` | `~/.config/starship.toml` | Prompt |
| `fastfetch/config.jsonc` | `~/.config/fastfetch/` | System info |
| `btop/btop.conf` | `~/.config/btop/` | Monitor |
| `xsecurelock/env.sh` | `~/.config/xsecurelock/` | Lock screen env |
| `session/xinitrc` | `~/.xinitrc` | Session entry |
| `session/Xresources` | `~/.Xresources` | X resources |
| `session/atelier.desktop` | `/usr/share/xsessions/` | DM session entry |
| `shell/bashrc.d-atelier.sh` | `/etc/bash/bashrc.d/` | Shell aliases + starship |
| `colors/tokyo-night.conf` | *(reference only)* | Palette notes |
| `nvidia/` | `atelier-nvidia` package | Proprietary NVIDIA modprobe/X11 glue |
| `xlibre/` | `atelier-xlibre-repo` package | External repo conf + public key |
| `void-repo/` | `atelier-void-repo` package | GraeWolf personal Void repo conf + public key |
| `wallpapers/` | `/usr/share/atelier/wallpapers/` | Desktop backgrounds (default: nord.png) |

## Theming

- **Palette:** Tokyo Night dark (`colors/tokyo-night.conf`)
- **Icons:** Papirus-Dark (package depend)
- **GTK base:** Yaru-dark (Void package `yaru`) + Tokyo Night CSS overrides in `gtk-3.0`/`gtk-4.0`
- **Qt:** Fusion + custom Tokyo Night color schemes via qt5ct/qt6ct
- **Fonts:** Fira Code + Nerd Symbols (JetBrains Mono planned; not required yet)

## Editing workflow

1. Edit files under `configs/`
2. Run `scripts/sync-atelier-config-files.sh` to refresh `packages/atelier-config/files/`
3. Rebuild `atelier-config` when the personal repo build exists (Step 3)

## Session start

From a TTY after login: `startx` (uses `~/.xinitrc` → `exec bspwm`).

Display managers can use the `Atelier` session (`atelier.desktop`).

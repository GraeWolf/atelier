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

## Theming

- **Palette:** Tokyo Night dark (`colors/tokyo-night.conf`)
- **Icons:** Papirus-Dark (package depend)
- **GTK base:** Adwaita-dark + CSS color overrides (no separate GTK theme package required for MVP)
- **Qt:** Fusion + custom Tokyo Night color schemes via qt5ct/qt6ct
- **Fonts:** Fira Code + Nerd Symbols (JetBrains Mono planned; not required yet)

## Editing workflow

1. Edit files under `configs/`
2. Run `scripts/sync-atelier-config-files.sh` to refresh `packages/atelier-config/files/`
3. Rebuild `atelier-config` when the personal repo build exists (Step 3)

## Session start

From a TTY after login: `startx` (uses `~/.xinitrc` → `exec bspwm`).

Display managers can use the `Atelier` session (`atelier.desktop`).

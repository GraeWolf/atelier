# Configuration sources

Canonical desktop and theming configuration for Atelier.

These files are the **source of truth**. The `atelier-config` XBPS package installs them into `/etc/skel` (and a few system paths) so new users get a complete themed bspwm session (Tokyo Night by default).

## Layout

| Path | Installs to | Component |
|------|-------------|-----------|
| `bspwm/bspwmrc` | `~/.config/bspwm/bspwmrc` | Window manager |
| `sxhkd/sxhkdrc` | `~/.config/sxhkd/sxhkdrc` | Hotkeys |
| `polybar/` | `~/.config/polybar/` | Status bar |
| `rofi/` | `~/.config/rofi/` | Launcher |
| `picom/picom.conf` | `~/.config/picom/` | Compositor |
| `ghostty/config` | `~/.config/ghostty/` | Terminal |
| `nvim/` | `~/.config/nvim/` | Neovim (voidwolf-based; theme from `atelier-theme`) |
| `keybinds/cheatsheet.txt` | `~/.config/atelier/keybinds.txt` + `/usr/share/doc/atelier/` | Super+k cheat sheet |
| `session/atelier-keybinds` | `/usr/bin/atelier-keybinds` | Floating keybind TUI launcher |
| `session/atelier-screenshot` | `/usr/bin/atelier-screenshot` | Region/window/full capture (clipboard) |
| `session/atelier-power-menu` | `/usr/bin/atelier-power-menu` | Rofi lock/logout/suspend/reboot/off |
| `session/atelier-scratchpad` | `/usr/bin/atelier-scratchpad` | Sticky hidden scratchpad |
| `session/atelier-btop` | `/usr/bin/atelier-btop` | Floating btop launcher |
| `session/atelier-menu` | `/usr/bin/atelier-menu` | Nested system menu (Super+Alt+Space) |
| `session/atelier-pkg` | `/usr/bin/atelier-pkg` | XBPS install/remove/update (fzf; from Install menu) |
| `session/atelier-theme` | `/usr/bin/atelier-theme` | Palette apply / wallpaper recolor / from-wallpaper |
| `themes/` | `/usr/share/atelier/themes/` | Named palettes (tokyo-night, nord, catppuccin-mocha) |
| `themes/templates/` | `/usr/share/atelier/templates/` | Per-app color templates |
| `gtk/` | `~/.config/gtk-3.0`, `gtk-4.0` | GTK theme overrides |
| `qt/` | `~/.config/qt5ct`, `qt6ct` | Qt theming via qt5ct/qt6ct |
| `starship/starship.toml` | `~/.config/starship.toml` | Prompt |
| `fastfetch/config.jsonc` | `~/.config/fastfetch/` | System info |
| `btop/btop.conf` | `~/.config/btop/` | Monitor |
| `xsecurelock/env.sh` | `~/.config/xsecurelock/` | Lock screen env |
| `ssh/agent-env.sh` | `~/.config/ssh/agent-env.sh` | Session ssh-agent (xinitrc + bashrc.d) |
| `session/xinitrc` | `~/.xinitrc` | Session entry |
| `session/Xresources` | `~/.Xresources` | X resources |
| `session/atelier.desktop` | `/usr/share/xsessions/` | DM session entry |
| `shell/bashrc.d-atelier.sh` | `/etc/bash/bashrc.d/` | Shell aliases + starship |
| `colors/tokyo-night.conf` | *(stub)* | Points at `themes/tokyo-night/` |
| `nvidia/` | `atelier-nvidia` package | Proprietary NVIDIA modprobe/X11 glue |
| `xlibre/` | `atelier-xlibre-repo` package | External repo conf + public key |
| `void-repo/` | `atelier-void-repo` package | GraeWolf personal Void repo conf + public key |
| `wallpapers/default.png` | `/usr/share/atelier/wallpaper.png` | Stock wallpaper (recolored per theme) |

## Theming

- **Engine:** `atelier-theme` — templates + `~/.config/atelier/current/`
- **Default palette:** Tokyo Night dark (`themes/tokyo-night/`)
- **Also shipped:** Nord, Catppuccin Mocha
- **Wallpaper:** one stock image, recolored with **gowall**
- **From image:** `atelier-theme from-wallpaper` (matugen, gowall extract fallback)
- **Icons:** Papirus-Dark (package depend)
- **GTK base:** Yaru-dark (Void package `yaru`) + CSS overrides using generated color defines
- **Qt:** Fusion + generated qt5ct/qt6ct color scheme
- **Fonts:** Fira Code + Nerd Symbols (JetBrains Mono planned; not required yet)

## Editing workflow

1. Edit files under `configs/`
2. Run `scripts/sync-atelier-config-files.sh` to refresh `packages/atelier-config/files/`
3. Rebuild `atelier-config` when the personal repo build exists (Step 3)

## Session start

From a TTY after login: `startx` (uses `~/.xinitrc` → `exec bspwm`).

Display managers can use the `Atelier` session (`atelier.desktop`).

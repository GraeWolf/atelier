# Configuration sources

Canonical desktop and theming configuration for Atelier.

These files are the **source** that XBPS config packages install onto the system. Prefer editing here, then packaging — do not treat a live machine as the only copy of truth.

## Layout

| Directory | Component |
|-----------|-----------|
| `bspwm/` | Window manager |
| `sxhkd/` | Hotkeys (if used) |
| `polybar/` | Status bar |
| `rofi/` | Launcher / menus |
| `picom/` | Compositor |
| `ghostty/` | Terminal |
| `gtk/` | GTK theme settings |
| `qt/` | Qt theme settings |
| `starship/` | Shell prompt |
| `fastfetch/` | System info |
| `btop/` | Process / system monitor |
| `xsecurelock/` | Screen lock integration |
| `fonts/` | Font-related config notes or files |

## Theming

Color scheme: **Tokyo Night (dark)**  
Fonts (from plan): FiraCode, JetBrains Mono, Nerd Font Symbols  

Apply consistently across GUI and TUI tools. Keep configs commented and easy to modify.

Config content is added primarily in **Phase 1 Step 2**.

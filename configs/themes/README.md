# Atelier themes

Each directory is a named palette. `atelier-theme set <name>` renders
`templates/` into `~/.config/atelier/current/` and recolors the stock
wallpaper (`configs/wallpapers/default.png`).

| File | Role |
|------|------|
| `colors.conf` | Required. Semantic + ANSI palette (`key=value`) |
| `nvim.colorscheme` | Optional. Neovim plugin scheme (else mini.base16) |
| `gtk.theme` | Optional. GTK theme name (default Yaru-dark) |
| `icons.theme` | Optional. Icon theme (default Papirus-Dark) |
| `bat.theme` | Optional. `BAT_THEME` value |

User themes live in `~/.config/atelier/themes/` and overlay these names.

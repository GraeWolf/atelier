# Atelier themes

Each directory is a named palette. `atelier-theme set <name>` renders
`templates/` into `~/.config/atelier/current/`.

| File | Role |
|------|------|
| `colors.conf` | Required. Semantic + ANSI palette (`key=value`) |
| `backgrounds/` | Optional. Still images (png, jpg, jpeg, webp). Same theme again cycles them |
| `nvim.colorscheme` | Optional. Neovim plugin scheme (else mini.base16) |
| `gtk.theme` | Optional. GTK theme name (default Yaru-dark) |
| `icons.theme` | Optional. Icon theme (default Papirus-Dark) |
| `bat.theme` | Optional. `BAT_THEME` value. `tokyonight` is not built into `bat`; the theme file is `configs/bat/tokyonight.tmTheme` |

User themes live in `~/.config/atelier/themes/` and overlay these names.
Extra stills for one theme can also live in `~/.config/atelier/backgrounds/<name>/`.
A theme with no stills recolors the stock wallpaper (`configs/wallpapers/default.png`).

User templates in `~/.config/atelier/templates/*.tpl` are applied first.
`~/.config/atelier/hooks/theme-set` runs after a switch when it is executable.
It receives the theme name. A failing hook is reported and the palette stays.

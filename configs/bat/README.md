# bat theme

`tokyonight.tmTheme` is the Tokyo Night Sublime theme from
[folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim)
(`extras/sublime/tokyonight_night.tmTheme`), Apache-2.0. The license is
`LICENSE.tokyonight` beside the theme.

`bat` names a custom theme after the file, not the plist `name` key
(`TokyoNight`). The file is `tokyonight.tmTheme` so `BAT_THEME=tokyonight`
(from `themes/tokyo-night/bat.theme`) matches.

Installed to `/usr/share/atelier/bat/`. Interactive bash copies it into
`~/.config/bat/themes/` and runs `bat cache --build` when the copy or the
cache is older than the theme. `bat` has no built-in theme named
`tokyonight`; without this file it warns and uses the default.

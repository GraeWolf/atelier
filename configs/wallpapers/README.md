# Wallpapers

`default.png` (or `.jpg` / `.webp`) is the **stock** desktop image. `atelier-theme`
recolors it to the active palette (via gowall) when the theme has no
`backgrounds/` stills. A theme can ship its own still images and cycle them.

The file may be a JPEG saved as `.png`; packaging sniffs MIME and installs
`/usr/share/atelier/wallpaper.jpg` (or `.png`) accordingly.

`nord.png` and `catppuccin-mocha.png` are older palettized copies of the same
scene. They are **not** installed.

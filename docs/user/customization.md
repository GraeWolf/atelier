# Customization guide

Atelier is opinionated but meant to stay **easy to understand and modify**. Prefer small, documented changes.

## ssh-agent

Graphical sessions start one `ssh-agent` (socket under `$XDG_RUNTIME_DIR`). Interactive bash sources the same helper so terminals reuse it. Keys are **not** loaded automatically; the first `git push` / `ssh` in a session may still ask for the passphrase once.

Helper: `~/.config/ssh/agent-env.sh` (from `atelier-config`). Do not put private keys in the Atelier repo.

## Where configs live

| Area | Path |
|------|------|
| Window manager | `~/.config/bspwm/bspwmrc` |
| Hotkeys | `~/.config/sxhkd/sxhkdrc` |
| Bar | `~/.config/polybar/` |
| Launcher | `~/.config/rofi/` |
| Compositor | `~/.config/picom/picom.conf` |
| Terminal | `~/.config/ghostty/config` |
| Neovim | `~/.config/nvim/` (voidwolf-based; leader = Space) |
| Prompt | `~/.config/starship.toml` |
| GTK | `~/.config/gtk-3.0/`, `gtk-4.0/` |
| Qt | `~/.config/qt5ct/`, `qt6ct/` |
| Session | `~/.xinitrc`, `~/.Xresources` |
| Monitors | `~/.config/atelier/monitors.conf` (via `atelier-monitors`) |

Defaults are installed from **`atelier-config`** into `/etc/skel` for new users. Your home directory copies are yours to edit.

## Themes

Switch the whole desktop palette (terminals, GTK, Qt, polybar, rofi, neovim, btop, starship, lock screen) and recolor the stock wallpaper:

```bash
atelier-theme list
atelier-theme set tokyo-night    # default
atelier-theme set nord
atelier-theme set catppuccin-mocha
```

Or **Super+Alt+Space → Style → Theme** (direct: **Super+Ctrl+Shift+Space**).

Build a palette from an image (does **not** replace the wallpaper photo; it recolors the stock image):

```bash
atelier-theme from-wallpaper ~/Pictures/foo.jpg --name foo
```

Use a different photo as the recolor source:

```bash
atelier-theme wallpaper ~/Pictures/bar.png
```

Hand-made themes: copy a directory from `/usr/share/atelier/themes/` to `~/.config/atelier/themes/<name>/` and edit `colors.conf`. Template overrides: `~/.config/atelier/templates/*.tpl`.

Existing accounts created before the theme engine need the new skel includes (or a recopy of the listed configs from `/etc/skel`) plus one `atelier-theme set tokyo-night`.

### Apply on a running install (this machine)

From the git clone, after `./scripts/build-repo.sh`:

```bash
# 1. Official Void extras the engine uses
sudo xbps-install -S gowall matugen

# 2. New Atelier packages from the local repo
sudo xbps-install --repository=$PWD/repo/out -u atelier-config atelier-desktop

# 3. Existing home copies do not update with the package. Recopy the
#    files the engine now includes (back up first if you edited them):
for f in \
  .xinitrc \
  .config/bspwm/bspwmrc \
  .config/sxhkd/sxhkdrc \
  .config/polybar/config.ini \
  .config/polybar/net-status.sh \
  .config/ghostty/config \
  .config/rofi/config.rasi \
  .config/gtk-3.0/gtk.css \
  .config/gtk-4.0/gtk.css \
  .config/nvim/init.lua \
  .config/btop/btop.conf \
  .config/qt5ct/qt5ct.conf \
  .config/qt6ct/qt6ct.conf \
  .config/xsecurelock/env.sh
do
  cp -a "/etc/skel/$f" "$HOME/$f"
done

# 4. Generate ~/.config/atelier/current/ and recolor the wallpaper
atelier-theme set tokyo-night
```

Then Super+Escape (reload sxhkd) or log out and `startx` again. Theme picker: Super+Ctrl+Shift+Space.

### GTK theme (Yaru-dark + palette overlay)

Void does not ship an Adwaita-dark theme package. Atelier uses:

| Piece | Value |
|-------|--------|
| Base theme | **Yaru-dark** (package `yaru`, pulled by `atelier-config`) |
| Icons | **Papirus-Dark** |
| Cursor | **Yaru** |
| Palette tweaks | `~/.config/gtk-3.0/gtk.css` (and gtk-4.0) |

Session startup (`~/.xinitrc`) also sets GNOME interface keys via `gsettings` so **Nemo** and other GTK apps prefer dark mode:

- `org.gnome.desktop.interface gtk-theme` → `Yaru-dark`
- `org.gnome.desktop.interface color-scheme` → `prefer-dark`

If an existing account still looks light after an update, re-copy the skel GTK configs and re-login:

```bash
cp -a /etc/skel/.config/gtk-3.0 ~/.config/
cp -a /etc/skel/.config/gtk-4.0 ~/.config/
# merge ~/.xinitrc from /etc/skel/.xinitrc if you have not customized it
```

### Upstream source of truth (builders)

In the Git repository, edit `configs/` and rebuild packages — do not treat a single machine as the only copy.

## Tokyo Night palette (default)

| Role | Hex |
|------|-----|
| Background | `#1a1b26` |
| Foreground | `#c0caf5` |
| Blue | `#7aa2f7` |
| Magenta | `#bb9af7` |
| Red | `#f7768e` |
| Green | `#9ece6a` |
| Yellow | `#e0af68` |
| Cyan | `#7dcfff` |
| Comment | `#565f89` |

Live file: `/usr/share/atelier/themes/tokyo-night/colors.conf`. Also copied to `/usr/share/doc/atelier/tokyo-night-palette.conf`.

## Wallpaper

One stock image (`/usr/share/atelier/wallpaper.png`) is **recolored** to the active palette (`gowall`) into `~/.config/atelier/current/wallpaper.png`.

```bash
# change which photo is recolored (keeps the current colorscheme)
atelier-theme wallpaper ~/Pictures/my.png

# override source without the helper (then re-apply the theme)
cp ~/Pictures/my.png ~/.config/atelier/wallpaper.png
atelier-theme set "$(atelier-theme current)"
```

## Safe first edits

1. **Keybindings** — edit `~/.config/sxhkd/sxhkdrc`, then Super+Escape to reload.
2. **Bar modules** — edit `~/.config/polybar/config.ini`, re-login or re-run launch script.
3. **Terminal colors/font** — `~/.config/ghostty/config`.
4. **Wallpaper source** — `atelier-theme wallpaper` or Style → Wallpaper source.

## Fonts

Configs use **Fira Code** (package `font-firacode`) and **Symbols Nerd Font** (`nerd-fonts-symbols-ttf`), both pulled by `atelier-base`.

JetBrains Mono is still a planned personal package and is **not** required for a working desktop.

```bash
sudo xbps-install -S font-firacode nerd-fonts-symbols-ttf
```

## Rofi will not open a second time

If Super+d works once then fails with `Failed to create pid file: '/run/user/…/rofi.pid'`:

```bash
rm -f "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/rofi.pid" /tmp/runtime-$(id -u)/rofi.pid
pkill -x rofi 2>/dev/null || true
```

Current Atelier configs use `~/.config/rofi/atelier-rofi.sh` to clear stale PIDs and ensure `XDG_RUNTIME_DIR` is writable. Rebuild the ISO (or update `atelier-config` and re-copy skel configs) to pick that up.

## VMs and “invisible” text

Live ISOs are often tested in QEMU/VirtualBox. If the terminal or rofi looks empty:

1. Rebuild/update with current Atelier configs (picom uses `xrender`; fonts are Fira Code).
2. Log out and `startx` again so `~/.xinitrc` can enable software OpenGL in VMs.
3. Emergency terminal: if `xterm` is installed, Super+Enter falls back to it when ghostty fails.
4. On bare-metal NVIDIA, prefer real drivers (`atelier-setup-nvidia`) and do **not** set `LIBGL_ALWAYS_SOFTWARE=1` (export `ATELIER_FORCE_HW_GL=1` before `startx` if auto-detect misfires).

## Package updates

```bash
sudo xbps-install -Su
```

Atelier metapackages:

| Package | Purpose |
|---------|---------|
| `atelier-desktop` | Desktop stack + apps |
| `atelier-config` | Theme and session files |
| `atelier-nvidia` | Proprietary NVIDIA glue (optional) |

Do not remove `atelier-config` unless you intend to manage all configs yourself.

## What to avoid (MVP philosophy)

- Adding large desktop environments or a second WM “just in case”
- Unrelated package formats (keep pure XBPS)
- Full-disk encryption tooling (deferred past MVP)
- Opaque automation that hides where files live

## Further reading

- [desktop.md](desktop.md) — keybindings and apps  
- [nvidia.md](nvidia.md) — graphics drivers  
- [../build/architecture.md](../build/architecture.md) — design choices  

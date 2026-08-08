# Customization guide

Atelier is opinionated but meant to stay **easy to understand and modify**. Prefer small, documented changes.

## Where configs live

| Area | Path |
|------|------|
| Window manager | `~/.config/bspwm/bspwmrc` |
| Hotkeys | `~/.config/sxhkd/sxhkdrc` |
| Bar | `~/.config/polybar/` |
| Launcher | `~/.config/rofi/` |
| Compositor | `~/.config/picom/picom.conf` |
| Terminal | `~/.config/ghostty/config` |
| Prompt | `~/.config/starship.toml` |
| GTK | `~/.config/gtk-3.0/`, `gtk-4.0/` |
| Qt | `~/.config/qt5ct/`, `qt6ct/` |
| Session | `~/.xinitrc`, `~/.Xresources` |

Defaults are installed from **`atelier-config`** into `/etc/skel` for new users. Your home directory copies are yours to edit.

### Upstream source of truth (builders)

In the Git repository, edit `configs/` and rebuild packages — do not treat a single machine as the only copy.

## Tokyo Night palette (reference)

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

Also documented in `/usr/share/doc/atelier/tokyo-night-palette.conf` when `atelier-config` is installed.

## Wallpaper

Default background: **nord.png** via `feh`.

```bash
# shipped paths
ls /usr/share/atelier/wallpapers/

# switch to the alternate
feh --no-fehbg --bg-fill /usr/share/atelier/wallpapers/catppuccin-mocha.png

# persist for your user session (bspwmrc reads ATELIER_WALLPAPER if set, else nord)
# or edit ~/.config/bspwm/bspwmrc WALL= line / export ATELIER_WALLPAPER in ~/.xinitrc
```

To publish a new default for everyone, put the image in repo `configs/wallpapers/`, set `nord.png` (or change bspwmrc), rebuild packages/ISO.

## Safe first edits

1. **Keybindings** — edit `~/.config/sxhkd/sxhkdrc`, then Super+Escape to reload.
2. **Bar modules** — edit `~/.config/polybar/config.ini`, re-login or re-run launch script.
3. **Terminal colors/font** — `~/.config/ghostty/config`.
4. **Wallpaper** — set with a tool of your choice in `bspwmrc` (feh is not required by PLAN; add only if you want it).

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

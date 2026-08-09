# Desktop guide (bspwm)

Atelier uses a single fixed stack: **bspwm** + **sxhkd** + **picom** + **polybar** + **rofi** + **ghostty**.

Modifier key: **Super** (Windows / Command key).

## Essential keybindings

### Launch & apps

| Keys | Action |
|------|--------|
| Super+Enter | Terminal (ghostty; falls back to xterm) |
| Super+Shift+Enter | Terminal with neovim |
| Super+d | Application launcher (rofi; second press closes if still open) |
| Super+Shift+d | Run command (rofi) |
| Super+e | File manager (nemo) |
| Super+b | Browser (Brave if packaged; falls back to chromium/xdg-open) |

### Windows

| Keys | Action |
|------|--------|
| Super+w | Close window |
| Super+Shift+w | Kill window |
| Super+h/j/k/l | Focus left/down/up/right |
| Super+arrows | Focus (arrow keys) |
| Super+Shift+h/j/k/l | Swap with neighbor |
| Super+Alt+h/j/k/l | Resize |
| Super+f | Fullscreen |
| Super+t | Tiled |
| Super+Shift+Space | Floating toggle |
| Super+Ctrl+h/j/k/l | Preselect split direction |
| Super+Ctrl+Space | Cancel preselect |

### Desktops

| Keys | Action |
|------|--------|
| Super+1 … Super+6 | Switch to primary-monitor desktops 1–6 |
| Super+7 … Super+9 | Switch to secondary-monitor desktops 7–9 (dual-head) |
| Super+Shift+1 … 9 | Send window to that desktop (follow focus) |

On a **single** monitor, desktops **1–9** all live on that screen.

### Session

| Keys | Action |
|------|--------|
| Super+Shift+l | Lock (xsecurelock) |
| Super+Shift+q | Quit bspwm (end session) |
| Super+Shift+m | Multi-monitor layout wizard |
| Super+Shift+v | Volume mixer (pavucontrol) |
| Super+Escape | Reload sxhkd |
| Super+Shift+r | Restart bspwm |
| Media volume keys | Raise / lower / mute (via `pactl`) |

Full map: `~/.config/sxhkd/sxhkdrc` (from package `atelier-config`).

## Polybar

One bar per monitor (`atelier-primary` / `atelier-secondary`).

| Area | Behavior |
|------|----------|
| Primary bar | Desktops **1–6** (pinned), CPU, mem, **net**, volume, layout, **tray** |
| Secondary bar | Desktops **7–9** (pinned), same modules **without** tray |
| Volume | Icon + %; **scroll** wheel changes volume; right-click → pavucontrol |
| Network | Wi‑Fi or ethernet **icon** + up/down; **left-click** → floating `nmtui` |
| Tray | **Primary only** (X11 limitation) |

If the secondary bar is missing, ensure `monitor = ${env:MONITOR:}` is in the bar config and re-run `~/.config/polybar/launch.sh`.

Config: `~/.config/polybar/`. Restart bars: Super+Shift+r (bspwm reload) or re-login.

```bash
# manual restart
~/.config/polybar/launch.sh
```

## Compositor (picom)

Picom starts with the session (`bspwmrc`).

| Goal | How |
|------|-----|
| Less tearing / smoother video | `backend = glx`, `vsync = true`, fullscreen unredirect |
| Transparent terminals | Ghostty `background-opacity` + picom `opacity-rule` for ghostty/xterm |
| Opaque browsers | picom forces opacity 100% for Firefox/Brave/Chromium/Chrome |

Skip: `export ATELIER_SKIP_PICOM=1` before starting the session.  
Log: `/tmp/atelier-picom.log` if picom fails to start.

## Applications (default set)

| App | Role |
|-----|------|
| ghostty | Terminal |
| nemo | Files |
| neovim | Editor |
| thunderbird | Mail |
| audacity | Audio edit |
| xfburn | CD/DVD burn |
| ristretto | Images |
| btop / fastfetch | System monitor / info |
| eza, bat, tldr, yt-dlp, gcc | CLI tools |

Browser: **brave-origin** is planned as a personal package; until then the Super+b binding falls back.

## Sound

Atelier uses **PipeWire** (with PulseAudio compatibility). Daemons start from `~/.xinitrc` after dbus:

- `pipewire`
- `wireplumber`
- `pipewire-pulse`

| Check | Command / action |
|-------|------------------|
| Server up? | `pactl info` (should mention PipeWire) |
| GUI mixer | Super+Shift+v or `pavucontrol` |
| Polybar volume | Icon + % on the bar; scroll to change; right-click → pavucontrol |
| No sound after update | Log out and `startx` again so xinitrc starts PipeWire |
| Wrong output (HDMI vs speakers) | Pick default sink in pavucontrol |
| Permission denied on devices | User should be in group `audio` (`groups`) |

Skip session audio startup: `export ATELIER_SKIP_AUDIO=1` before `startx`.

Packages come from `atelier-desktop` (`pipewire`, `wireplumber`, `alsa-pipewire`, `pavucontrol`, `sof-firmware`, …).

## Monitors (1–2 displays MVP)

Layout is applied **before** bspwm starts (`atelier-monitors apply` from `~/.xinitrc`).

| Situation | What happens |
|-----------|----------------|
| One monitor | Auto; no prompt |
| Two monitors, first time (or cables changed) | Rofi asks primary + side (left/right/above/below) |
| Two monitors, saved config still valid | Applies `~/.config/atelier/monitors.conf` silently |
| Three or more | MVP: enable outputs with `xrandr --auto` only |

Workspaces after layout:

| Setup | Desktops |
|-------|----------|
| One screen | **1–9** on that monitor |
| Two screens | Primary **1–6**, secondary **7–9** |

Re-run layout wizard: **Super+Shift+m** or `atelier-monitors setup`.

```bash
# skip layout on next login
export ATELIER_SKIP_MONITORS=1

# force the wizard on next login
export ATELIER_MONITORS_FORCE=1
```

Log: `~/.cache/atelier/monitors.log`

## Tips

- Focus follows the mouse pointer (`focus_follows_pointer` in bspwm).
- Keep configs simple — Atelier prefers clarity over heavy automation.
- Theme colors: Tokyo Night dark (see customization guide).

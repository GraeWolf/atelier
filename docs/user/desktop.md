# Desktop guide (bspwm)

Atelier uses a single fixed stack: **bspwm** + **sxhkd** + **picom** + **polybar** + **rofi** + **ghostty**.

Modifier key: **Super** (Windows / Command key).

## Essential keybindings

Several chords are **Omarchy-inspired** (launcher on Super+Space, system menu on Super+Alt+Space, scratchpad, screenshots without a Print key, power menu) but adapted for **bspwm + X11**.

## System menu

**Super+Alt+Space** opens `atelier-menu` — a nested **rofi** control hub (same idea as Omarchy’s `omarchy-menu` + Walker, without Wayland/Quickshell).

| Entry | Action |
|-------|--------|
| Power | Same as Super+Ctrl+Escape (`atelier-power-menu`) |
| Lock | `atelier-lock` |
| Displays | Multi-monitor wizard |
| Audio | pavucontrol |
| Network | Floating `nmtui` |
| Install | XBPS Package / Remove / Update (`atelier-pkg`) |
| Capture | Screenshot menu |
| Activity | Floating btop |
| Scratchpad | Toggle scratchpad |
| Keybinds | Cheat sheet |
| Session | Reload sxhkd / restart bspwm |
| About | Short Atelier blurb |

**Install** (Omarchy-style, Void XBPS):

| Submenu | Action |
|---------|--------|
| Package | Floating terminal + **fzf** over available packages → `sudo xbps-install -S` (Tab multi-select; preview with alt-p) |
| Remove | **fzf** over manually installed packages → `sudo xbps-remove -R` |
| Update | `sudo xbps-install -Su` in a floating terminal |

CLI: `atelier-pkg install`, `atelier-pkg remove`, `atelier-pkg update`.

CLI jump: `atelier-menu capture`, `atelier-menu install`, `atelier-menu power`, etc. Esc on a submenu returns to the main list (unless you jumped in via CLI).

### Launch & apps

| Keys | Action |
|------|--------|
| Super+Enter | Terminal (ghostty; falls back to xterm) |
| Super+Shift+Enter | Terminal with neovim |
| Super+Space | Application launcher (rofi; primary) |
| Super+d | Application launcher (alias) |
| Super+Alt+Space | System menu (nested rofi: power, displays, capture, …) |
| Super+Shift+d | Run command (rofi) |
| Super+Shift+F | File manager (nemo; primary) |
| Super+e | File manager (alias) |
| Super+b | Browser (Brave if packaged; falls back to chromium/xdg-open) |
| Super+Ctrl+T | Activity monitor (`btop`, floating) |
| Super+k | Keybind cheat sheet (floating; toggle) |

### Windows

| Keys | Action |
|------|--------|
| Super+w | Close window |
| Super+Shift+w | Kill window |
| Super+h/j/l | Focus left/down/right |
| Super+arrows | Focus (all directions; Up = north) |
| Super+Shift+h/j/k | Swap left / down / up |
| Super+Shift+arrows | Swap (all directions; Right = east) |
| Super+Alt+h/j/k/l | Resize |
| Super+f | Fullscreen |
| Super+t | Tiled |
| Super+Shift+Space | Floating |
| Super+Ctrl+h/j/k/l | Preselect split direction |
| Super+Ctrl+Space | Cancel preselect |
| Super+S | Scratchpad toggle (show/hide marked sticky floats) |
| Super+Alt+S | Send focused window to scratchpad (again to restore) |

### Desktops

| Keys | Action |
|------|--------|
| Super+1 … Super+6 | Switch to primary-monitor desktops 1–6 |
| Super+7 … Super+9 | Switch to secondary-monitor desktops 7–9 (dual-head) |
| Super+Shift+1 … 9 | Send window to that desktop (follow focus) |

On a **single** monitor, desktops **1–9** all live on that screen.

Bindings use desktop **names** (`bspc desktop -f 7`), not `^7` (which means “7th desktop in global order” and mis-fires when monitors are ordered secondary-first).

### Capture

No Print-Screen key required (Omarchy-style chords):

| Keys | Action |
|------|--------|
| Super+Ctrl+C | Screenshot menu (region / window / full) |
| Super+Shift+S | Region select → clipboard |
| Super+Shift+Ctrl+S | Full screen → clipboard |
| Super+Shift+Alt+S | Focused window → clipboard |

Files are also saved under `~/Pictures/Screenshots/` (`atelier-screenshot`; needs `maim` + `xclip`).

### Session

| Keys | Action |
|------|--------|
| Super+Shift+l | Lock screen (`atelier-lock` / xsecurelock) |
| Super+Ctrl+l | Lock screen (alias) |
| Super+Ctrl+Escape | Power menu (lock / logout / suspend / reboot / shutdown) |
| Super+Shift+q | Quit bspwm (end session) |
| Super+Shift+m | Multi-monitor layout wizard |
| Super+Shift+v | Volume mixer (pavucontrol) |
| Super+Escape | Reload sxhkd |
| Super+Shift+r | Restart bspwm |
| Media volume keys | Raise / lower / mute (±5%; Alt+ for ±1%) |
| Brightness keys | Raise / lower via `brightnessctl` when present |

Full map: `~/.config/sxhkd/sxhkdrc` (from package `atelier-config`).

## Polybar

One bar per monitor (`atelier-primary` / `atelier-secondary`).

| Area | Behavior |
|------|----------|
| Primary bar | Desktops **1–6** as **icons** (bspwm module), CPU, mem, net, volume, layout, **tray** |
| Secondary bar | Desktops **7–9** as icons, same modules **without** tray |
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
| neovim | Editor (Atelier config under `~/.config/nvim`; plugins on first launch) |
| thunderbird | Mail |
| audacity | Audio edit |
| xfburn | CD/DVD burn |
| ristretto | Images |
| btop / fastfetch | System monitor / info |
| eza, bat, tldr, yt-dlp, gcc | CLI tools |

Browser: install **brave-origin** from the GraeWolf repo (`sudo xbps-install -S brave-origin`). Super+b falls back until it is installed.

## Screen lock

| Item | Default |
|------|---------|
| Manual lock | **Super+Shift+l** → `atelier-lock` |
| Idle lock | After **5 minutes** idle (`xset s`; via xss-lock) |
| Suspend | **2 minutes after lock** while still locked (`loginctl suspend`) |
| Password feedback | Jumping **cursor** (not hex digits) |
| Picom flash on unlock | Disabled (`XSECURELOCK_COMPOSITE_OBSCURER=0`) |

Env (in `~/.config/xsecurelock/env.sh` and/or session):

```bash
export ATELIER_LOCK_IDLE_SEC=300      # seconds idle before lock
export ATELIER_LOCK_CYCLE_SEC=30      # dimmer phase before lock
export ATELIER_LOCK_SUSPEND_SEC=120   # seconds after lock before suspend (0=off)
# export ATELIER_SKIP_LOCK_SUSPEND=1
# export ATELIER_SKIP_IDLE_LOCK=1
```

Password prompt styles (`XSECURELOCK_PASSWORD_PROMPT`): `cursor` (default here), `asterisks`, `hidden`, … — not `time_hex`.

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

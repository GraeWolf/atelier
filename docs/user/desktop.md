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
| Super+1 … Super+9, Super+0 | Switch to desktop 1–10 |
| Super+Shift+1 … 0 | Send window to desktop (follow) |

### Session

| Keys | Action |
|------|--------|
| Super+Shift+l | Lock (xsecurelock) |
| Super+Shift+q | Quit bspwm (end session) |
| Super+Shift+m | Multi-monitor layout wizard |
| Super+Escape | Reload sxhkd |
| Super+Shift+r | Restart bspwm |

Full map: `~/.config/sxhkd/sxhkdrc` (from package `atelier-config`).

## Polybar

The top bar shows workspaces, date/time, CPU, memory, audio, and keyboard layout.  
Config: `~/.config/polybar/config.ini`. Restart via bspwm reload or re-login.

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

## Monitors (1–2 displays MVP)

Layout is applied **before** bspwm starts (`atelier-monitors apply` from `~/.xinitrc`).

| Situation | What happens |
|-----------|----------------|
| One monitor | Auto; no prompt |
| Two monitors, first time (or cables changed) | Rofi asks primary + side (left/right/above/below) |
| Two monitors, saved config still valid | Applies `~/.config/atelier/monitors.conf` silently |
| Three or more | MVP: enable outputs with `xrandr --auto` only |

Workspaces: one screen → desktops **1–10**; two screens → primary **1–5**, secondary **6–10**.

Re-run anytime: **Super+Shift+m** or `atelier-monitors setup`.

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

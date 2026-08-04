# Desktop guide (bspwm)

Atelier uses a single fixed stack: **bspwm** + **sxhkd** + **picom** + **polybar** + **rofi** + **ghostty**.

Modifier key: **Super** (Windows / Command key).

## Essential keybindings

### Launch & apps

| Keys | Action |
|------|--------|
| Super+Enter | Terminal (ghostty; falls back to xterm) |
| Super+Shift+Enter | Terminal with neovim |
| Super+d | Application launcher (rofi drun) |
| Super+Shift+d | Run command (rofi run) |
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

## Tips

- Focus follows the mouse pointer (`focus_follows_pointer` in bspwm).
- Keep configs simple — Atelier prefers clarity over heavy automation.
- Theme colors: Tokyo Night dark (see customization guide).

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
| Install | XBPS Package / Remove / Update (`atelier-pkg`); Web App add/remove (`atelier-webapp`) |
| Capture | Screenshot menu |
| Activity | Floating btop |
| Scratchpad | Toggle scratchpad |
| Keybinds | Cheat sheet |
| Session | Reload sxhkd / restart bspwm |
| Style | Theme / From wallpaper / Wallpaper source (`atelier-theme`) |
| About | Short Atelier blurb |

**Install** (Omarchy-style, Void XBPS):

| Submenu | Action |
|---------|--------|
| Package | Floating terminal + **fzf** over available packages → `sudo xbps-install -S` (Tab multi-select; preview with alt-p) |
| Remove | **fzf** over manually installed packages → `sudo xbps-remove -R` |
| Update | `sudo xbps-install -Su` in a floating terminal |
| Web App | Add or remove a Chromium `--app` launcher (rofi prompts; see **Web apps** below) |

CLI: `atelier-pkg install`, `atelier-pkg remove`, `atelier-pkg update`. Web apps: `atelier-webapp install`, `atelier-webapp remove`, `atelier-menu webapp`.

CLI jump: `atelier-menu capture`, `atelier-menu install`, `atelier-menu power`, etc. Esc on a submenu returns to the main list (unless you jumped in via CLI).

### Launch & apps

| Keys | Action |
|------|--------|
| Super+Enter | Terminal (ghostty; falls back to xterm) |
| Super+Shift+Enter | Terminal with neovim |
| Super+Space | Application launcher (rofi; primary) |
| Super+d | Application launcher (alias) |
| Super+Alt+Space | System menu (nested rofi: power, style, displays, capture, …) |
| Super+Ctrl+Shift+Space | Theme picker |
| Super+Shift+d | Run command (rofi) |
| Super+Shift+F | File manager (nemo; primary) |
| Super+e | File manager (alias) |
| Super+b | Browser (Brave if packaged; falls back to chromium/xdg-open) |
| Super+Shift+G | Grok web app (`https://grok.com`) |
| Super+Shift+E | Proton Mail web app (`https://mail.proton.me`) |
| Super+Shift+X | X web app (`https://x.com`) |
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
| Super+Ctrl+Escape | Power menu (lock / logout / suspend / hibernate / reboot / shutdown) |
| Super+Shift+q | Quit bspwm (end session) |
| Super+Shift+m | Multi-monitor layout wizard |
| Super+Shift+v | Volume mixer (pavucontrol) |
| Super+Escape | Reload sxhkd |
| Super+Shift+r | Restart bspwm |
| Media volume keys | Raise / lower / mute (±5%; Alt+ for ±1%) |
| Brightness keys | Raise / lower the **panel** via `brightnessctl` when present |
| Keyboard light keys | Raise / lower / toggle **keyboard** backlight (`atelier-kbd` on ASUS ROG, else `brightnessctl`) |

Full map: `~/.config/sxhkd/sxhkdrc` (from package `atelier-config`).

## Web apps

Sites can run as **standalone windows** (Brave/Chromium `--app=`, no tab bar or omnibox) instead of a normal browser tab. They appear in the app launcher (`Super+Space`) and use a shared browser profile, so log in once in Brave (`Super+b`) first.

| App | URL | Keys |
|-----|-----|------|
| Grok | https://grok.com | Super+Shift+G |
| Proton Mail | https://mail.proton.me | Super+Shift+E |
| X | https://x.com | Super+Shift+X |

Add another site: **Super+Alt+Space → Install → Web App → Add** (name, URL, optional icon URL; empty icon fetches a favicon). Remove only **user-added** apps from the same submenu; the three packaged defaults stay with `atelier-config`.

CLI:

```bash
atelier-webapp launch https://example.com --class=my-app
atelier-webapp install "Name" "https://example.com"
atelier-webapp remove
atelier-webapp list
```

Needs a Chromium-family browser (`brave-origin` from the GraeWolf repo, or `chromium`). Firefox has no `--app` mode. Override the binary with `ATELIER_WEBAPP_BROWSER` if needed.

A second press of a web-app hotkey **focuses** the existing window (matched by `WM_CLASS`) instead of opening a duplicate.

## Polybar

One bar per monitor (`atelier-primary` / `atelier-secondary`).

| Area | Behavior |
|------|----------|
| Primary bar | Desktops **1–6** as **icons** (bspwm module), battery, CPU, mem, net, volume, layout, **tray** |
| Secondary bar | Desktops **7–9** as icons, same modules **without** tray |
| Battery | Icon + % **before CPU**; **hidden** when no battery (desktops) |
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

Mail clients that use **libsecret** (for example Melia from the GraeWolf repo) store passwords in **gnome-keyring**, started from `~/.xinitrc` and unlocked at TTY login. First launch after setup: enter the mailbox password once. See [customization.md](customization.md#gnome-keyring-secret-service).

## Screen lock

| Item | Default |
|------|---------|
| Manual lock | **Super+Shift+l** → `atelier-lock` |
| Idle lock | After **5 minutes** idle (`xset s`; via xss-lock) |
| Suspend | **2 minutes after lock** while still locked. With a swapfile this is `suspend-then-hibernate` (sleep, then hibernate after **30 minutes** asleep). |
| Hibernate | Power menu (**Super+Ctrl+Escape**); needs a swapfile (`sudo atelier-setup-swap`). Immediate, not the 30-minute delay. |
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

### Hibernate resume then reboot

MediaTek **mt7921e** (RZ608 / MT7921/MT7922 Wi-Fi, common on ASUS AMD laptops) times out during hibernate resume (`Message 00020007`, `pci_pm_restore` error **-110**). Resume hangs or resets to GRUB; a leftover image then makes the next boot try S4 again (double GRUB, then a LUKS prompt that may hang on the same driver). Atelier unloads `mt7921e` in `/etc/elogind/system-sleep/atelier-wifi` before sleep and reloads it after, and sets `mt7921e.disable_aspm=1` plus `/sys/power/pm_async=0`.

Without a package update:

```bash
sudo mkdir -p /etc/elogind/system-sleep /etc/modprobe.d
sudo install -m755 configs/elogind/system-sleep/atelier-wifi \
	/etc/elogind/system-sleep/atelier-wifi
sudo install -m644 configs/modprobe.d/atelier-wifi.conf \
	/etc/modprobe.d/atelier-wifi.conf
echo 0 | sudo tee /sys/power/pm_async
```

Then `loginctl hibernate` again. Going black with a blinking cursor for a while **before** power-off is normal (NVIDIA VT switch + Wi-Fi unload). Some ASUS firmware always shows GRUB twice after S4; that is OK if the **second** boot asks for LUKS and restores the lock screen.

Wi-Fi is taken down for sleep/hibernate (MediaTek `mt7921e` PCI restore timeout) and brought back **after you unlock**, not during the lock prompt. If it stays down:

```bash
sudo modprobe mt7921e
nmcli radio wifi on
```

Check `/var/log/atelier-pm.log` for `atelier-wifi: post: reload finished`.

If a previous failed resume left a bad image (GRUB twice, LUKS missing on the first try, black screen after the second), **wipe the leftover S4 header** before trying again:

```bash
sudo install -m755 configs/session/atelier-setup-swap /usr/bin/atelier-setup-swap
sudo atelier-setup-swap --clear-image
```

On LUKS installs, resume must wait for `/dev/mapper/cryptroot` (not the inner ext4 UUID). Re-run `sudo atelier-setup-swap --yes` so GRUB gets `resume=/dev/mapper/cryptroot`, then reboot once, then hibernate.

Hybrid NVIDIA (amdgpu panel + dGPU): install the NVIDIA hook and **disable Void’s vendor copy**. That script always calls `nvidia-sleep.sh hibernate`; running it twice deadlocks freeze (`nvidia-sleep.sh blocked on an rw-semaphore`, `Device or resource busy`).

```bash
sudo install -m755 configs/elogind/system-sleep/atelier-nvidia \
	/etc/elogind/system-sleep/atelier-nvidia
sudo chmod a-x /usr/libexec/elogind/system-sleep/nvidia.sh \
	/usr/lib/elogind/system-sleep/nvidia.sh \
	/usr/lib64/elogind/system-sleep/nvidia.sh 2>/dev/null || true
```

Black screen with a blinking cursor after LUKS usually means the session restored but the GPU did not. Switch TTY (`Ctrl+Alt+F2`). If `loginctl reboot` hangs, hold the power button, boot normally, clear the image, then retry with the hooks.

If the session comes back from hibernate and the machine reboots by itself about 30–60 seconds later, Atelier has no persistent syslog, so kernel messages from the dying session are lost. `atelier-config` installs `/etc/elogind/system-sleep/atelier-pm-log`, which appends a pre/post snapshot to **`/var/log/atelier-pm.log`** and writes `still-alive` lines at 15/30/45/60/90 seconds after resume.

Without a package update yet:

```bash
sudo mkdir -p /etc/elogind/system-sleep
sudo install -m755 /path/to/atelier/configs/elogind/system-sleep/atelier-pm-log \
	/etc/elogind/system-sleep/atelier-pm-log
sudo install -m755 /path/to/atelier/configs/session/atelier-lock /usr/bin/atelier-lock
```

Then reproduce once and inspect the log **after the surprise reboot**:

```bash
sudo less /var/log/atelier-pm.log
lsmod | grep -iE 'sp5100_tco|iTCO|wdt|watchdog'
cat /proc/cmdline
```

| What you see | Meaning |
|--------------|---------|
| `post hibernate` but no `still-alive` | Reset inside ~15s of resume |
| `still-alive 15s` / `30s` then silence | Reset in that window (watchdog / GPU timeout) |
| `NVRM`, `Xid`, `PreserveVideoMemory` in the dmesg tail | NVIDIA dGPU failed after S4 (desktop can still look fine on the iGPU) |
| `sp5100_tco` / watchdog identity in the snapshot | AMD TCO watchdog; do **not** add `nowatchdog` on the desktop PC |
| `rtc0 wakealarm` still set on `post hibernate` | Leftover RTC from `suspend-then-hibernate` |

### `Sleep verb "hibernate" not supported`

`loginctl` always lists the verb. elogind still refuses unless the **kernel** advertises hibernation (`disk` in `/sys/power/state`). Swap and `resume=` can be perfect and the verb still fails.

```bash
sudo install -m755 configs/session/atelier-setup-swap /usr/bin/atelier-setup-swap
sudo atelier-setup-swap --status
```

| `--status` | Meaning |
|------------|---------|
| `sysfs state: freeze mem` and `sysfs disk: [disabled]` | Kernel `hibernation_available()` is false. Not a swap/`resume=` bug. |
| lockdown `[none]` | Secure Boot is **not** the cause |
| lockdown `integrity` / `confidentiality` | Disable Secure Boot in firmware |
| secretmem maps listed | A process called `memfd_secret` (often Brave/Chromium). Close it and re-check `/sys/power/state` |
| `resume 0:0` with `resume_offset>0` | `sudo atelier-setup-swap --apply-resume` |
| empty `/proc/swaps` | `swapon` failed |

If lockdown is `[none]` but `disk` is still missing:

```bash
cat /sys/power/state
# close Brave/Chromium, then:
cat /sys/power/state
```

If `disk` appears after closing the browser, hibernate is blocked only while `memfd_secret` users exist. Optional kernel param `secretmem.enable=0` disables that syscall so hibernate stays available. `--apply-resume` cannot override a disabled `disk`.

A/B (one cycle each; wait 3 minutes after resume):

1. Power menu **Hibernate** (immediate). If this stays up, the bug is the 30-minute sleep-then-hibernate path, not S4 itself.
2. `loginctl suspend` (RAM only). If this also reboots after resume, it is watchdog/GPU, not the hibernation image.
3. Note whether windows from before hibernate are still open (true restore vs a cold boot), GRUB/firmware POST (true reboot vs X dying), and whether the fans spin up just before the reset.

Do not change GRUB or NVIDIA module options until that log points at a cause. Hybrid NVIDIA notes: [nvidia.md](nvidia.md).

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
- Theme: `atelier-theme` (default Tokyo Night; see customization guide). ASUS ROG keyboard RGB follows `accent` when `atelier-asus` is installed.

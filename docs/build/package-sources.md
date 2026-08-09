# Package sources (Phase 1 Step 1)

Mapping of packages from `PLAN.md` to Void XBPS names, personal packages, and external repositories.

Verified against the host’s official Void `x86_64` repository (2026-08-02). Names can drift; re-check with `xbps-query -Rs` before ISO builds.

## Source legend

| Source | Meaning |
|--------|---------|
| **void** | Official Void main repository |
| **void-nonfree** | Official Void nonfree subrepository (enable `void-repo-nonfree` when needed) |
| **personal** | Built by Atelier into the personal XBPS repo (`packages/`, `repo/`) |
| **external** | Third-party XBPS repository (not Atelier-built); wired at ISO/install time |
| **gap** | Required by PLAN but not yet packaged anywhere we control |

## Display server

| PLAN / role | XBPS name | Source | Notes |
|-------------|-----------|--------|-------|
| Xlibre | `xlibre` | **external** | [xlibre-void](https://github.com/xlibre-void/xlibre). Enable via package `atelier-xlibre-repo` + `atelier-setup-xlibre`. |
| X.Org (live/fallback) | `xorg-minimal`, `xorg-server` | void | Default live ISO; recovery if Xlibre fails. |

### NVIDIA (primary desktop)

| Role | XBPS name | Source | Notes |
|------|-----------|--------|-------|
| Enable nonfree | `void-repo-nonfree` | void | Ships nonfree mirror snippet |
| Proprietary stack | `nvidia` | **void-nonfree** | Pulls libs/dkms/firmware; **x86_64 only** |
| Atelier glue | `atelier-nvidia` | **personal** | Blacklist nouveau, modeset, xorg snippet, setup script |

See [nvidia.md](nvidia.md).

## Desktop stack (PLAN §7)

| PLAN | XBPS name | Source | Notes |
|------|-----------|--------|-------|
| bspwm | `bspwm` | void | |
| (hotkeys) | `sxhkd` | void | Not named in PLAN but required for a usable bspwm setup |
| picom | `picom` | void | |
| polybar | `polybar` | void | |
| rofi | `rofi` | void | |
| ghostty | `ghostty` | void | Optional: `ghostty-terminfo` |
| xsecurelock | `xsecurelock` | void | |
| xss-lock | `xss-lock` | void | |
| starship | `starship` | void | |
| fastfetch | `fastfetch` | void | |
| btop | `btop` | void | |

Minimal X11 session helpers (not listed in PLAN, but needed to start/control X):

| Role | XBPS name | Source |
|------|-----------|--------|
| Start X | `xinit` | void |
| Root color / WM hooks | `xsetroot` | void |
| X resources | `xrdb` | void |

GTK / icon theming glue (not named in PLAN §7, required for consistent dark apps):

| Role | XBPS name | Source | Notes |
|------|-----------|--------|-------|
| Dark GTK theme | `yaru` | void | Provides **Yaru-dark**; Void has no Adwaita-dark theme package. Dep of `atelier-config`. |
| Icon theme | `papirus-icon-theme` | void | **Papirus-Dark** in configs |
| Qt theme tools | `qt5ct`, `qt6ct` | void | Tokyo Night color schemes under `configs/qt/` |

## Applications (PLAN §7)

| PLAN | XBPS name | Source | Notes |
|------|-----------|--------|-------|
| brave-origin | *(none)* | **gap → personal** | No Brave package in official Void. Ship as personal package (e.g. `brave-origin` or `brave-bin`) in a later step. Not a hard depend of `atelier-desktop` yet. |
| nemo | `nemo` | void | File manager; may pull GTK stack |
| neovim | `neovim` | void | |
| thunderbird | `thunderbird` | void | |
| audacity | `audacity` | void | |
| xfburn | `xfburn` | void | |
| ristretto | `ristretto` | void | |
| exa | `eza` | void | Official Void: `exa` is a transitional dummy; real package is `eza` (provides modern `ls`) |
| bat | `bat` | void | |
| tldr | `tldr` | void | |
| yt-dlp | `yt-dlp` | void | |
| gcc | `gcc` | void | |

## Fonts (PLAN §8)

| PLAN | XBPS name | Source | Notes |
|------|-----------|--------|-------|
| FiraCode | `font-firacode` | void | |
| JetBrains Mono | *(none)* | **gap → personal** | Not in official Void under this name. Add personal `font-jetbrains-mono` (or similar) later. |
| Nerd Font Symbols | `nerd-fonts-symbols-ttf` | void | Symbols-only; prefer over full `nerd-fonts` for size |

## Metapackages / config (Atelier personal)

| Package | Role | Source |
|---------|------|--------|
| `atelier-base` | Fonts available today + light session glue | **personal** |
| `atelier-config` | Tokyo Night configs → `/etc/skel`, xsessions, bashrc.d | **personal** |
| `atelier-desktop` | Full PLAN desktop stack + apps + `atelier-config` | **personal** |
| `atelier-installer` | Whole-disk graphical installer (`atelier-install`) | **personal** |
| `atelier-nvidia` | Proprietary NVIDIA configs + depends on `nvidia` | **personal** |
| `atelier-xlibre-repo` | Xlibre external repo key + xbps.d | **personal** |

Config sources live under `configs/`; sync into the package with `scripts/sync-atelier-config-files.sh`.

## Explicit gaps (track until closed)

1. **brave-origin** — personal package required  
2. **JetBrains Mono** — personal font package required  
3. **Xlibre** — external repo integration required  
4. ~~Installer~~ — addressed by `atelier-installer` (yad/zenity/dialog)  

## Audio stack (PipeWire)

Desktop sound is **required** for a usable session (polybar volume module, Audacity, browsers, etc.). Atelier uses **PipeWire** with PulseAudio compatibility (not the classic `pulseaudio` server).

| Role | XBPS name | Source | Notes |
|------|-----------|--------|-------|
| Server + `pipewire-pulse` | `pipewire` | void | Started from `~/.xinitrc` |
| Session manager | `wireplumber` | void | |
| elogind integration | `wireplumber-elogind` | void | Void/runit |
| ALSA → PipeWire | `alsa-pipewire` | void | |
| CLI (`pactl`) | `pulseaudio-utils` | void | Also pulled by `pipewire` |
| GUI mixer | `pavucontrol` | void | Super+Shift+v |
| Intel SOF firmware | `sof-firmware` | void | Common laptops/desktops |
| ALSA tools | `alsa-utils` | void | Diagnostics |
| Realtime scheduling | `rtkit` | void | Recommended |

Do **not** install the full `pulseaudio` package alongside this stack.  
Bluetooth audio (`libspa-bluetooth`, etc.) is optional later.

## Intentionally not added (minimalism)

Unless later requested or proven required for a listed app to run:

- Display managers (lightdm/sddm) — session start approach TBD with Xlibre  
- dunst, extra screenshots tools  
- Full `xorg` / `xorg-video-drivers` metapackage (NVIDIA is Step 6; Xlibre is external)  
- NetworkManager on every install (live ISO includes it; revisit for installer UX)

## How to re-verify

```bash
xbps-query -R <pkgname>          # exact package
xbps-query -Rs <keyword>         # search
```

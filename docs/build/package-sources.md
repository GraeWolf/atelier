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
| Xlibre | `xlibre` (expected) | **external** | Not in official Void. Community Void packaging: [xlibre-void](https://github.com/xlibre-void) (GitHub releases repo). Exact package set and install steps land when ISO work starts (Step 4+). |
| X.Org (fallback only) | `xorg-server`, `xorg-minimal` | void | **Not** the Phase 1 target. Documented only for VM testing if Xlibre is awkward early. |

Do **not** list Xlibre as a hard `depends` of `atelier-desktop` until the external repo is integrated and package names are confirmed in-tree.

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

## Metapackages (Atelier personal)

| Package | Role | Source |
|---------|------|--------|
| `atelier-base` | Fonts available today + light session glue | **personal** |
| `atelier-desktop` | Full PLAN desktop stack + apps (minus gaps) | **personal** |

Config packages (Tokyo Night, bspwmrc, etc.) are **Step 2**, not these metapackages.

## Explicit gaps (track until closed)

1. **brave-origin** — personal package required  
2. **JetBrains Mono** — personal font package required  
3. **Xlibre** — external repo integration required  
4. **atelier-config-*** — Step 2  
5. **Installer GUI toolkit** (e.g. `zenity` / `yad`) — Step 5 only; not part of desktop meta  

## Intentionally not added (minimalism)

Unless later requested or proven required for a listed app to run:

- Display managers (lightdm/sddm) — session start approach TBD with Xlibre  
- feh, dunst, extra screenshots tools  
- Full `xorg` / `xorg-video-drivers` metapackage (NVIDIA is Step 6; Xlibre is external)  
- PipeWire / PulseAudio as hard depends (audio stack may be pulled by apps; revisit if live session needs it)  
- NetworkManager (Void live often uses dhcpcd/wpa; revisit for installer UX)

## How to re-verify

```bash
xbps-query -R <pkgname>          # exact package
xbps-query -Rs <keyword>         # search
```

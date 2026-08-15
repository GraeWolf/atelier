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
| **graewolf** | [GraeWolf/void-repo](https://github.com/GraeWolf/void-repo) signed GitHub release repo (`atelier-void-repo`) |

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
| brave-origin | `brave-origin` | **graewolf** | From [GraeWolf/void-repo](https://github.com/GraeWolf/void-repo). Live/installed systems enable the repo via `atelier-void-repo`. Optional install (large). |
| dropbox | `dropbox` | **void-nonfree** | Required desktop package; needs `void-repo-nonfree`. Hard depend of `atelier-desktop`; always installed by `atelier-install`. |
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

## XDG user directories

| Role | XBPS name | Source | Notes |
|------|-----------|--------|-------|
| User dirs tool | `xdg-user-dirs` | void | Required; installer runs `xdg-user-dirs-update` as the new user |
| GTK integration | `xdg-user-dirs-gtk` | void | Recommended with nemo / GTK apps |

## Metapackages / config (Atelier personal)

| Package | Role | Source |
|---------|------|--------|
| `atelier-base` | Fonts available today + light session glue | **personal** |
| `atelier-config` | Tokyo Night configs → `/etc/skel`, xsessions, bashrc.d | **personal** |
| `atelier-desktop` | Full PLAN desktop stack + apps + `atelier-config` | **personal** |
| `atelier-installer` | Whole-disk graphical installer (`atelier-install`) | **personal** |
| `atelier-nvidia` | Proprietary NVIDIA configs + depends on `nvidia` | **personal** |
| `atelier-xlibre-repo` | Xlibre external repo key + xbps.d | **personal** |
| `atelier-void-repo` | GraeWolf void-repo public key + xbps.d | **personal** |
| `atelier-windows-vm` | Optional Windows VM (Docker + FreeRDP + dockur image) | **personal** (post-MVP; opt-in) |

Config sources live under `configs/`; sync into the package with `scripts/sync-atelier-config-files.sh`.

### Optional Windows VM (`atelier-windows-vm`)

| Role | XBPS / image | Source | Notes |
|------|--------------|--------|-------|
| Atelier package | `atelier-windows-vm` | **personal** | CLI, setup helper, desktop entry; not on ISO lists |
| Docker engine | `docker`, `docker-cli`, `docker-compose` | void | Host stack via depends |
| FreeRDP | `freerdp` (`xfreerdp3`) | void | Session client |
| TUI / notify | `dialog`, `libnotify` | void | Wizard + rofi error UX |
| Guest image | `dockurr/windows` | Docker registry | Pulled at user install time; not XBPS |

See [windows-vm.md](windows-vm.md).

## Closed / resolved

1. ~~**brave-origin**~~ — [GraeWolf/void-repo](https://github.com/GraeWolf/void-repo); live/ISO via `atelier-void-repo`  
2. ~~**Public package hosting**~~ — same repo (GitHub Releases `x86_64`)  
3. ~~**Installer**~~ — `atelier-installer` wizard  
4. ~~**Xlibre wiring**~~ — `atelier-xlibre-repo` + setup helper (package still external)  

## Explicit gaps (still open)

1. **JetBrains Mono** — personal font package if PLAN fonts are required as-named (UI currently uses Fira Code)  
2. Full-disk encryption — deferred past MVP  

### GraeWolf personal Void repository (public)

| Item | Value |
|------|--------|
| Templates / source | https://github.com/GraeWolf/void-repo |
| Binary URL | `https://github.com/GraeWolf/void-repo/releases/download/x86_64/` |
| Packages (examples) | `brave-origin`, `obsidian`, `melia` |
| Atelier glue | package `atelier-void-repo` (xbps.d + public key) |
| Live ISO | conf + key in `iso/include-src/`; mklive `-r` includes the URL |
| Setup helper | `atelier-setup-void-repo` |
| Status | **In use** — public hosting and brave-origin resolved |

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

# AGENTS.md — Atelier Linux

Atelier is a custom Linux distribution built on a Void Linux base. It is a systemd-free system focused on a clean, minimal desktop with custom tooling and TUI integrations.

## Stack

- **Base**: Void Linux
- **Init**: runit
- **Graphics**: NVIDIA RTX 4060 Ti (DKMS packages)
- **Window manager**: bspwm (started via `startx` / `.xinitrc`)
- **Package manager**: xbps
- **Primary language/tools**: Shell scripts, occasional C++ or other languages for custom tools, package templates

## How to work in this repository

1. **Prefer minimal, targeted changes.** Fix the specific problem with the smallest set of changes that are likely to work. Avoid large refactors unless explicitly requested.
2. **Show a plan first** for non-trivial changes (config tweaks, new scripts, package changes, suspend/resume fixes, etc.). Wait for approval before writing files.
3. **Create a branch and open a draft pull request.** Do not merge. The maintainer will test on hardware and merge if the change works.
4. In every PR description include:
   - What changed and why
   - How to test it
   - Any known limitations or follow-up steps
5. Document non-obvious changes with short comments or notes in the relevant files.
6. When researching issues (NVIDIA suspend/resume, runit services, xbps packaging, bspwm behavior, etc.), cite relevant sources or known-good approaches from Void/Arch documentation when useful.

## Common task patterns

- System configuration fixes (kernel parameters, modprobe options, runit services, power management)
- Packaging work (xbps templates, custom packages)
- Window manager and desktop configuration (bspwm, `.xinitrc`, autostart)
- Scripts for setup, maintenance, or TUI tools
- Investigating hardware-specific issues (especially NVIDIA) and proposing testable fixes

## Constraints


## Current Focus (MVP)
- Bootable live ISO with gum (TUI) installer
- NVIDIA proprietary driver support
- Personal repository integrated
- Fully themed bspwm desktop with the exact application list from PLAN.md
- Basic user documentation + detailed build documentation
- This is a real system the maintainer runs. Changes that affect boot, suspend/resume, graphics, or package installation must be conservative and easy to revert.
- Prefer solutions that stay within Void’s conventions (runit, xbps, etc.) rather than introducing systemd units or foreign package managers.
- Do not assume a display manager is present; the system uses `startx` + bspwm.
d423d6f (Adding the AGENTS.md for Grok Build)

## Testing expectation

Most system-level changes (especially graphics, suspend, input, or boot-related) cannot be fully verified in a generic environment. Provide clear test steps so the maintainer can validate on the actual hardware.

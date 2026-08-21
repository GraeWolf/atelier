# Atelier Linux — Agent Rules

## Core Principles
- Always start non-trivial work in Plan Mode. Never write or edit files until a plan is approved.
- Prefer small, reviewable changes. No large refactors without an explicit plan.
- Never touch signing keys, private keys, secrets, or credential files.
- Never run destructive package/ISO build commands without explicit approval.
- Keep the working tree clean. Prefer feature branches.

## Forbidden / High-Risk
- Do not edit or read any files matching: **/*.key, **/*.pem, **/*secret*, **/.env*, **/private/, **/keys/
- Do not run `rm -rf`, full system package operations, or ISO burning/writing without asking.
- Do not push to main or tag releases automatically.

## Preferred Workflow
1. Explore / understand current state
2. Produce a clear plan (what files change, why, risks, verification steps)
3. Wait for approval
4. Implement in small steps
5. Verify (build scripts, package checks, lint where applicable)

## Project Conventions
- Follow existing packaging style and directory layout.
- Document any new packages or significant changes.
- Prefer reproducible, declarative approaches where possible.

# AGENTS.md – Atelier Linux

This file gives Grok Build consistent instructions when working on the Atelier project.

## Project Summary
Atelier is a personal, opinionated Linux distribution based on Void Linux.
Primary goals: extreme minimalism, simplicity, elegant Tokyo Night theming, and a ready-to-use bspwm desktop.

## Key Rules
- Always follow the current PLAN.md as the source of truth.
- Prefer extreme minimalism — do not add packages or features unless they are explicitly listed in the plan or requested.
- Keep configurations clean, readable, and easy to understand/modify.
- Maintain consistent theming via `atelier-theme` (Tokyo Night dark is the default palette) across GTK, Qt, terminals, TUIs, rofi, polybar, etc.
- Use pure XBPS + the personal extra repository. Do not introduce other package formats unless asked.
- Init system is runit. Display server is Xlibre. Window manager is bspwm (single fixed setup).

## Current Focus (MVP)
- Bootable live ISO with graphical installer
- NVIDIA proprietary driver support
- Personal repository integrated
- Fully themed bspwm desktop with the exact application list from PLAN.md
- Basic user documentation + detailed build documentation

## Working Style
- Make small, focused changes.
- Explain what you are doing and why when making non-trivial decisions.
- When creating or editing configuration files, keep them well-commented.
- Prefer clarity over cleverness.

## Multi-machine Note
This repository is used on two machines via Git. Always assume the local clone may have been updated by the other machine. Prefer reading PLAN.md and existing files before making assumptions.

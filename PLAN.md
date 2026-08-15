1. Project Overview
Atelier is a personal, opinionated Linux distribution built on Void Linux. It delivers a ready-to-use system with carefully chosen presets, configurations, and a consistent elegant aesthetic. The project is primarily a learning exercise, with the secondary goal of being useful to beginners who want a simple, opinionated system.

2. Development Environment

Primary development environment: Void Linux running under Windows WSL2
Packaging, configuration, scripting, and repository work will be done in WSL2
ISO building can be performed in WSL2
Full testing of the live ISO, graphical installer, NVIDIA drivers, and desktop session will require exporting the ISO and testing on real hardware or a suitable virtual machine


3. Multi-machine Development
The project will be developed across two machines using a single Git repository as the source of truth, with Grok Build (the local CLI) running independently on each machine.
Core approach

All project files live in one Git repository (GitHub, Codeberg, or similar).
The same repository is cloned on both machines.
Grok Build is started inside the local clone on whichever machine is being used.
Git (pull → work → commit → push) keeps both machines synchronized.

Recommended daily workflow
Bashgit pull                          # get latest changes
grok                              # start Grok Build in the project directory
# ... work ...
git add .
git commit -m "Clear description of changes"
git push
Keeping the two Grok Build instances aligned

Code, configs, and scripts: Git is the single source of truth.
Project instructions / plan: Keep the main plan document, README.md, and any AGENTS.md or custom instructions inside the repository so both Grok Build instances read the same context.
Conversation history: Grok Build sessions are local and do not sync automatically. Treat each session as a working session against the shared codebase.
Commit frequently with clear messages so progress is visible across machines.

This setup allows flexible work on the WSL2 machine for most development and on the second machine (desktop) for hardware-specific testing (especially NVIDIA and final ISO validation).

4. Goals & Success Criteria
MVP (Phase 1) Success Criteria

Bootable live ISO
Graphical installer
NVIDIA proprietary driver support
Personal extra repository integrated
Fully themed bspwm desktop with the complete application list
Consistent Tokyo Night theming (GUI + TUI)
Basic user documentation + detailed build documentation


5. Design Philosophy

Extreme minimalism
Simplicity and clarity over features
Opinionated defaults
Easy to understand and modify
Elegant, clean, and aesthetically consistent (Tokyo Night dark)
Security is important, but full-disk encryption is deferred past MVP


6. Technical Specifications













































ComponentChoiceNotesBaseVoid LinuxRollingInit systemrunitPackage managerXBPS (pure) + personal repoDisplay serverXlibreExternal repoWindow managerbspwmSingle fixed setupPrimary hardwareDesktop PCNVIDIA proprietary requiredDevelopment hostVoid Linux on Windows WSL2 + second machineGit-synced

7. Desktop & Default Applications
Desktop stack: bspwm + picom + polybar + rofi + ghostty + xsecurelock/xss-lock + starship + fastfetch + btop
Applications:
brave-origin, nemo, neovim, thunderbird, audacity, xfburn, ristretto, exa, bat, tldr, yt-dlp, gcc, dropbox

8. Aesthetics

Color scheme: Tokyo Night (dark)
Fonts: FiraCode, JetBrains Mono, Nerd Font Symbols
Apply theming as widely as possible (GTK, Qt, terminals, TUIs, icons, cursor, rofi, polybar, etc.)


9. Installation Experience

Traditional live ISO
Graphical installer
Live environment should ideally show the final themed desktop
NVIDIA support and personal repository must work in both live and installed systems


10. Documentation

Detailed step-by-step build documentation (core learning goal)
User-facing documentation shipped with the distro (quick-start + customization guide)


11. Development Phases
Phase 1 – MVP

Working live ISO + graphical installer
NVIDIA proprietary support
Personal repository integrated
Fully themed bspwm desktop + complete app list
Documentation (build + user)

Phase 1 is broken into smaller milestones (Step 0–7). See docs/build/phases.md for status and details.
Architecture decisions for Phase 1: docs/build/architecture.md
End-to-end build guide: docs/build/end-to-end.md
User documentation: docs/user/

Public package hosting: GraeWolf/void-repo (https://github.com/GraeWolf/void-repo) provides packages such as brave-origin; enabled via atelier-void-repo on live and installed systems.

Later phases: Extra hardware support, encryption, further polish, remaining package gaps (e.g. JetBrains Mono), etc.

Atelier — optional Windows VM
=============================

Package: atelier-windows-vm
Status: install / launch / status / stop / remove implemented

Purpose
-------
Opt-in Windows 11 guest for Office-class apps via Docker (dockur/windows) + FreeRDP.
Not part of atelier-desktop. Not on the live ISO package lists.

Setup (once)
------------
  sudo xbps-install -Sy atelier-windows-vm
  sudo atelier-setup-docker
  # log out and back in (docker group)

  docker info
  docker compose version

Use
---
  atelier-windows-vm install     # dialog wizard; watch http://127.0.0.1:8006
  atelier-windows-vm launch      # FreeRDP; stops VM when RDP closes
  atelier-windows-vm launch -k   # keep VM running after RDP
  atelier-windows-vm status
  atelier-windows-vm stop
  atelier-windows-vm remove      # keeps ~/Atelier/Windows

Paths
-----
  compose   ~/.config/atelier/windows/docker-compose.yml  (mode 0600)
  storage   ~/.local/share/atelier/windows
  shared    ~/Atelier/Windows
  last-error  $XDG_RUNTIME_DIR/atelier-windows-vm-last-error.txt
              (or under /tmp if runtime dir is missing)

Desktop
-------
  Rofi/drun entry: "Windows" -> atelier-windows-vm launch
  Errors use notify-send + last-error file (Terminal=false).

FreeRDP
-------
  Client: xfreerdp3 (package freerdp)
  Password via /from-stdin (not on argv) when supported
  Auto-stop on RDP exit unless --keep-alive

Security
--------
  docker group ≈ root. Only ~/Atelier/Windows is shared (two-way).
  Compose holds credentials (mode 0600).

Policy
------
  Host: Void XBPS. Guest image: dockurr/windows (registry). Needs /dev/kvm.

Build notes
-----------
  docs/build/windows-vm.md in the Atelier source tree.

Atelier — optional Windows VM
=============================

Package: atelier-windows-vm
Status: install / status / stop / remove implemented; launch (FreeRDP) still pending

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

Install guest
-------------
  atelier-windows-vm install
  # follow dialog wizard; watch progress at http://127.0.0.1:8006

  atelier-windows-vm status
  atelier-windows-vm stop
  atelier-windows-vm remove   # keeps ~/Atelier/Windows

  atelier-windows-vm launch   # FreeRDP — not fully implemented yet

Paths
-----
  compose   ~/.config/atelier/windows/docker-compose.yml  (mode 0600)
  storage   ~/.local/share/atelier/windows
  shared    ~/Atelier/Windows

Username / password (wizard)
----------------------------
  Username: A-Z a-z 0-9 . _ - (default: docker)
  Password: letters, digits, !@#$%^&*_+.=- (default: admin)
  Empty fields use defaults. Exotic passwords: set inside Windows, edit compose carefully.

Security
--------
  docker group ≈ root. Only ~/Atelier/Windows is shared (two-way, untrusted).
  Compose holds credentials (mode 0600).

Policy
------
  Host: Void XBPS. Guest image: dockurr/windows (registry). Needs /dev/kvm.

Build notes
-----------
  docs/build/windows-vm.md in the Atelier source tree.

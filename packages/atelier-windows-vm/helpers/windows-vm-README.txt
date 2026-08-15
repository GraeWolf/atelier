Atelier — optional Windows VM
=============================

Package: atelier-windows-vm
Status: setup-docker implemented; install/launch lifecycle still incomplete

Purpose
-------
Opt-in Windows 11 guest for Office-class apps via Docker (dockur/windows) + FreeRDP.
Not part of atelier-desktop. Not on the live ISO package lists.

Setup (once)
------------
  sudo xbps-install -Sy atelier-windows-vm   # from personal repo when available
  sudo atelier-setup-docker                  # Docker service + docker/kvm groups
  # log out and back in (or: newgrp docker)

  docker info
  docker compose version   # or: docker-compose version

Commands
--------
  atelier-windows-vm install    # dialog wizard (not fully implemented yet)
  atelier-windows-vm launch     # FreeRDP (not fully implemented yet)
  atelier-windows-vm stop
  atelier-windows-vm status
  atelier-windows-vm remove
  atelier-windows-vm help

Paths
-----
  compose   ~/.config/atelier/windows/docker-compose.yml
  storage   ~/.local/share/atelier/windows
  shared    ~/Atelier/Windows   (only host folder exposed to guest)

Example compose
---------------
  /usr/share/atelier/windows/docker-compose.yml.example

Policy
------
Host packages: Void XBPS (docker, freerdp, dialog, libnotify, …).
Runtime image: dockurr/windows (Docker registry; not an XBPS package).
Requires KVM (/dev/kvm). Prefer bare metal for real use.

Docker group is roughly root-equivalent on the host — intentional for this path.

Build notes
-----------
See docs/build/windows-vm.md in the Atelier source tree.

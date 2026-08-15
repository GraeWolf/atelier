Atelier — optional Windows VM (skeleton)
========================================

Package: atelier-windows-vm
Status: skeleton only — install/launch/setup-docker not fully implemented yet

Purpose
-------
Opt-in Windows 11 guest for Office-class apps via Docker (dockur/windows) + FreeRDP.
Not part of atelier-desktop. Not on the live ISO package lists.

Planned commands
----------------
  sudo atelier-setup-docker     # once: Docker service + docker/kvm groups
  atelier-windows-vm install    # dialog wizard; pull image; start guest
  atelier-windows-vm launch     # FreeRDP to 127.0.0.1:3389
  atelier-windows-vm stop
  atelier-windows-vm status
  atelier-windows-vm remove

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

Build notes
-----------
See docs/build/windows-vm.md in the Atelier source tree.

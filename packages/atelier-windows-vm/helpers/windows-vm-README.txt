Atelier — optional Windows VM
=============================

Package: atelier-windows-vm 0.2.0

Opt-in Windows 11 via Docker (dockur/windows) + FreeRDP.
Not part of atelier-desktop. Not on live ISO lists.

Setup (once)
------------
  sudo xbps-install -Sy atelier-windows-vm
  sudo atelier-setup-docker
  # re-login

  docker info && docker compose version

Install
-------
  atelier-windows-vm install              # dialog wizard
  atelier-windows-vm install --yes \      # non-interactive
    --ram 4G --cpus 2 --disk 64G --force

  # password via env (preferred for scripts):
  ATELIER_WINDOWS_PASSWORD=... atelier-windows-vm install --yes --force

  # pin image digest (optional):
  --image dockurr/windows@sha256:...
  # or ATELIER_WINDOWS_IMAGE=...

Use
---
  http://127.0.0.1:8006     # install progress
  atelier-windows-vm launch
  atelier-windows-vm launch -k
  atelier-windows-vm status|stop
  atelier-windows-vm remove [--yes]

Paths
-----
  ~/.config/atelier/windows/docker-compose.yml   (0600)
  ~/.local/share/atelier/windows
  ~/Atelier/Windows
  last-error: $XDG_RUNTIME_DIR/atelier-windows-vm-last-error.txt

Security
--------
  docker group ≈ root. Only ~/Atelier/Windows shared (two-way).
  Full guide: docs/user/windows-vm.md (source tree) or project website docs.

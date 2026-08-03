Atelier — Xlibre (external Void packages)
=========================================

Xlibre is the PLAN display server. It is not in official Void; Atelier enables
the community xlibre-void repository:

  https://github.com/xlibre-void/xlibre

Package atelier-xlibre-repo installs:
  - /etc/xbps.d/99-repository-xlibre.conf
  - public signing key under /var/db/xbps/keys/

Install Xlibre
--------------
  sudo atelier-setup-xlibre

Or manually:
  sudo xbps-install -S xlibre

Notes
-----
- Replaces X.Org server packages; keep a recovery plan (TTY + xbps).
- Proprietary NVIDIA (atelier-setup-nvidia) should be installed first or after;
  both target X11-compatible driver ABIs — test on hardware.
- Default live ISO may still use xorg-minimal for VM testing.

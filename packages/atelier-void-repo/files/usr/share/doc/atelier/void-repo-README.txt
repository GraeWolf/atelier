Atelier — GraeWolf personal Void repository
============================================

Source templates: https://github.com/GraeWolf/void-repo
Binary packages:  https://github.com/GraeWolf/void-repo/releases/tag/x86_64

This external repository provides packages not in official Void, including:

  - brave-origin
  - obsidian
  - melia

Enable / re-enable:

  sudo atelier-setup-void-repo
  sudo xbps-install -S
  sudo xbps-install -S brave-origin

Live ISO and installed systems that include the package "atelier-void-repo"
already ship the xbps.d snippet and public signing key.

Signing key fingerprint (hex filename under /var/db/xbps/keys/):

  94:85:7f:4b:ca:9e:0a:8c:e9:e5:42:dc:07:40:57:74

signature-by: Kelly McCuddy <graewolf@use.startmail.com>

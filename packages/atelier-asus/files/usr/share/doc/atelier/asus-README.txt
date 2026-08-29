Atelier — ASUS ROG keyboard backlight
=====================================

Package: atelier-asus (opt-in; not part of atelier-desktop; not on the live ISO)

What it fixes
-------------
On ASUS ROG laptops such as the Zephyrus G15 GA503RM, hid-asus exposes
/sys/class/leds/asus::kbd_backlight but initializes brightness to 0.
The keys are on during POST, then go dark after Linux boots.

RGB colour is a separate Aura HID report on USB 0b05:19b6. When this
package is installed, atelier-theme sets a static colour from the palette
accent (or colors.conf keyboard= override).

This package:
- Restores brightness on LED device add (default 2 of 3)
- Restores the last Aura colour on that same udev event
- Provides atelier-kbd for step / toggle / restore / color
- Grants group input write access to the Aura hidraw
- Relies on sxhkd XF86KbdBrightness* bindings from atelier-config

Install
-------
  sudo xbps-install -S atelier-asus
  sudo udevadm control --reload
  sudo udevadm trigger --subsystem-match=hidraw --action=add
  atelier-kbd restore
  atelier-theme set tokyo-night   # colours the keys if a session is running

Fn keys (after reloading sxhkd: Super+Escape)
---------------------------------------------
  Keyboard light up / down  —  step brightness
  Keyboard light toggle     —  off / last on

CLI
---
  atelier-kbd restore
  atelier-kbd up | down | toggle
  atelier-kbd get
  atelier-kbd set 3
  atelier-kbd color '#7aa2f7'

Last non-zero brightness: /var/lib/atelier/kbd-brightness
Last colour:              /var/lib/atelier/kbd-color
(udev restore runs as root so both persist across reboot; skipped in initramfs)

Theme override
--------------
In a theme colors.conf, optional:

  keyboard=#ff9e64

If unset, atelier-theme uses accent.

Not included
------------
asusctl / asusd, OpenRGB, fan curves, charge limit, GPU MUX,
breathe/rainbow/per-key effects.

Remove
------
  sudo xbps-remove atelier-asus

# ASUS ROG keyboard backlight

On some ASUS ROG laptops (including the Zephyrus G15 **GA503RM**), the RGB
keyboard is on during firmware POST and then goes **dark after Linux boots**.

The kernel driver (`hid-asus`) exposes `/sys/class/leds/asus::kbd_backlight`
but starts it at brightness **0**. Setting that sysfs value turns the lights
back on.

**Colour** is a separate Aura HID report on USB `0b05:19b6`. With this
package installed, `atelier-theme` sets a static colour from the palette
`accent` (Tokyo Night blue, Nord cyan, Catppuccin blue, …).

## Install (opt-in)

`atelier-asus` is **not** part of `atelier-desktop` and is **not** on the live
ISO. Install it from the personal Atelier repo:

```bash
sudo xbps-install -S atelier-asus
sudo udevadm control --reload
sudo udevadm trigger --subsystem-match=hidraw --action=add
atelier-kbd restore
```

Reload sxhkd (`Super+Escape`) so the keyboard-light keys pick up
`atelier-kbd` if your session was started before the package existed.

Re-apply the current theme so the keys pick up `accent`:

```bash
atelier-theme set "$(atelier-theme current)"
```

## Everyday use

| Control | Action |
|---------|--------|
| Keyboard light up / down | Step 0–3 |
| Keyboard light toggle | Off, or last non-zero |
| Style menu / `atelier-theme set` | Static colour from `accent` |
| `atelier-kbd restore` | Last brightness (or 2) and last colour |
| `atelier-kbd set 3` | Maximum brightness |
| `atelier-kbd color '#7aa2f7'` | Static colour |

Last non-zero brightness: `/var/lib/atelier/kbd-brightness`  
Last colour: `/var/lib/atelier/kbd-color`  
(the udev restore runs as root)

Screen brightness keys still control the **panel** (`amdgpu_bl0` / similar).

### Optional colour override

In a theme `colors.conf`:

```
keyboard=#ff9e64
```

If unset, the keyboard uses `accent`.

## Uninstall

```bash
sudo xbps-remove atelier-asus
```

## Not in this package

`asusctl` / `asusd`, OpenRGB, fan curves, charge limit, GPU MUX, or
animated Aura modes (breathe, rainbow, per-key).

See also `/usr/share/doc/atelier/asus-README.txt`.

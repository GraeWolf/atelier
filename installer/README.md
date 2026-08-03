# Graphical installer

Custom **simple** GUI installer for Atelier (not Calamares).

## MVP scope (Phase 1 Step 5)

Intended minimum flow:

- Disk selection
- Simple whole-disk install (no full-disk encryption)
- User creation, hostname, timezone/locale basics
- Package install from official Void + personal repo
- Bootloader setup
- Launch entry from the live desktop (menu / icon)

## Non-goals for MVP

- Encryption
- Complex custom partition layouts (unless trivially cheap later)
- Multi-boot polish beyond basic correctness

## Implementation notes

Toolkit and language will be chosen at implementation time for simplicity and maintainability (e.g. shell + Zenity/YAD, or another lightweight option). Prefer clarity over cleverness.

Work starts in **Phase 1 Step 5**, after a bootable live ISO exists.

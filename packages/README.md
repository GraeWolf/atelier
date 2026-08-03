# Packages

XBPS package sources (templates and package files) for Atelier.

## Purpose

- Metapackages (`atelier-base`, `atelier-desktop`, …)
- Config packages that install files from `../configs/`
- Any Atelier-specific packages not available (or not suitable) from official Void

## Conventions

- Follow existing Void packaging style where possible
- Prefer declarative depends for metapackages
- Keep templates and install paths easy to read
- Document new packages when they are added

Package work starts in **Phase 1 Step 1** (lists and metapackages) and **Step 2** (config packages).

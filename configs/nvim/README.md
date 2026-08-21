# Neovim config (Atelier)

Canonical Neovim configuration for Atelier users.

**Upstream origin:** [voidwolf nvim](https://codeberg.org/Graewolf/voidwolf/src/branch/main/nvim)  
Synced into this tree for distro packaging (`atelier-config` → `/etc/skel/.config/nvim`).

## Requirements

- Neovim **0.12+** (`vim.pack` plugin manager)
- Optional: `tree-sitter-cli` (Void package) so Treesitter grammars can compile
- First launch downloads plugins listed in `lua/pack.lua` / lockfile

## Layout

| File | Role |
|------|------|
| `init.lua` | Entry + `atelier-theme` / Tokyo Night fallback |
| `lua/options.lua` | Options |
| `lua/keymaps.lua` | Keymaps (leader = Space) |
| `lua/pack.lua` | Plugins + mini.* |
| `lua/treesitter.lua` | Parsers |
| `lua/lsp.lua` | Mason + LSP |
| `lua/commands.lua` | PackAdd / PackDel / PackUpdate |
| `nvim-pack-lock.json` | Locked plugin revisions |

Edit here, then `./scripts/sync-atelier-config-files.sh` and rebuild `atelier-config`.

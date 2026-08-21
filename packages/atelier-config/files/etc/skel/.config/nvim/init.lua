vim.opt.termguicolors = true
require("options")
require("keymaps")
require("commands")
require("pack")
require("treesitter")
require("lsp")

local theme = vim.fn.expand("~/.config/atelier/current/nvim.lua")
if vim.fn.filereadable(theme) == 1 then
	dofile(theme)
else
	pcall(vim.cmd.colorscheme, "tokyonight-night")
end


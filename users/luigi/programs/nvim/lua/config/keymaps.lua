-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- -----------------------------------------------------------------------------
-- Directional Navigation Remaps:
--   j -> Left
--   k -> Right
--   h -> Down
--   l -> Up
-- -----------------------------------------------------------------------------
map({ "n", "v", "x", "o" }, "j", "h", { desc = "Move Left", remap = false })
map({ "n", "v", "x", "o" }, "k", "l", { desc = "Move Right", remap = false })
map({ "n", "v", "x", "o" }, "h", "v:count == 0 ? 'gj' : 'j'", { desc = "Move Down", expr = true, remap = false })
map({ "n", "v", "x", "o" }, "l", "v:count == 0 ? 'gk' : 'k'", { desc = "Move Up", expr = true, remap = false })

-- Window navigation matching the new directional layout (Ctrl + direction)
map("n", "<C-j>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-k>", "<C-w>l", { desc = "Go to Right Window", remap = true })
map("n", "<C-h>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-l>", "<C-w>k", { desc = "Go to Upper Window", remap = true })

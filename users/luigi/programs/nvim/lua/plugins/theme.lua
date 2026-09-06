-- =============================================================================
-- Active Neovim Theme Selector
-- Toggle by commenting / uncommenting ONE of the lines below:
-- =============================================================================
local active_style = "tokyonight" -- Style 1: High-Contrast Solid (Tokyo Night)
-- local active_style = "catppuccin" -- Style 2: Translucent Aesthetic (Catppuccin Mocha)
-- =============================================================================

if active_style == "tokyonight" then
  return {
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      opts = {
        style = "night",
        transparent = false,
        terminal_colors = true,
        styles = {
          sidebars = "dark",
          floats = "dark",
        },
      },
    },
    {
      "LazyVim/LazyVim",
      opts = {
        colorscheme = "tokyonight-night",
      },
    },
  }
else
  return {
    {
      "catppuccin/nvim",
      name = "catppuccin",
      opts = {
        flavour = "mocha",
        transparent_background = true,
      },
    },
    {
      "LazyVim/LazyVim",
      opts = {
        colorscheme = "catppuccin",
      },
    },
  }
end

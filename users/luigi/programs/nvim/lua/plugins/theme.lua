-- =============================================================================
-- Active Neovim Theme Configuration
-- =============================================================================
-- NOTE: This file is dynamically generated and deployed by NixOS / Home Manager
-- via `users/luigi/theme.nix`.
--
-- To change the global theme across Neovim, WezTerm, Bat, and Zsh, edit:
--   `users/luigi/theme.nix` -> change `selectedStyle` -> run `rebuild`.
--
-- Any manual changes made directly to this file in the nix store will be
-- overwritten on the next rebuild.
-- =============================================================================

local style = vim.g.theme_style or "tokyonight"

if style == "catppuccin" then
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
else
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
end

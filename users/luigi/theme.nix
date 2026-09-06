{ lib, ... }:

let
  # ============================================================================
  # GLOBAL THEME SWITCHER
  # Toggle between the two aesthetic styles across your entire environment
  # (WezTerm, Neovim, Zsh shell prompt, Bat) by commenting / uncommenting ONE line:
  # ============================================================================
  selectedStyle = "tokyonight";   # Style 1: High-Contrast Solid (Tokyo Night, Opacity 1.0, Solid Neovim, RobbyRussell Zsh)
  # selectedStyle = "catppuccin"; # Style 2: Translucent Aesthetic (Catppuccin Mocha, Opacity 0.80, Translucent Neovim, Floating Zsh)
  # ============================================================================

  presets = {
    tokyonight = {
      name = "tokyonight";
      wezterm = {
        colorScheme = "Tokyo Night";
        opacity = "1.0";
      };
      neovim = {
        colorscheme = "tokyonight-night";
        transparent = false;
        themePlugin = ''
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
        '';
      };
      zsh = {
        theme = "robbyrussell";
        extraConfig = "";
      };
      bat = {
        theme = "TwoDark";
      };
    };

    catppuccin = {
      name = "catppuccin";
      wezterm = {
        colorScheme = "Catppuccin Mocha";
        opacity = "0.80";
      };
      neovim = {
        colorscheme = "catppuccin";
        transparent = true;
        themePlugin = ''
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
        '';
      };
      zsh = {
        theme = "random";
        extraConfig = ''
          # Randomly select between floating cloud, lambda, and minimalist time tracking themes
          ZSH_THEME_RANDOM_CANDIDATES=( "cloud" "lambda" "fino-time" )
        '';
      };
      bat = {
        theme = "Catppuccin Mocha";
      };
    };
  };
in
presets.${selectedStyle}

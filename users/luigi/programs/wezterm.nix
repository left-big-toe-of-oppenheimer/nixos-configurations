{ config, pkgs, ... }:

let
  theme = import ../theme.nix;
in
{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()

      -- Font configuration for maximum sharpness and readability
      config.font = wezterm.font_with_fallback {
        'JetBrains Mono',
        'Noto Sans Mono',
        'DejaVu Sans Mono',
      }
      config.font_size = 14.0
      config.line_height = 1.15

      -- Global style selected via theme.nix
      ${if theme == "tokyonight" then ''
        config.color_scheme = 'Tokyo Night'
        config.window_background_opacity = 1.0
      '' else ''
        config.color_scheme = 'Catppuccin Mocha'
        config.window_background_opacity = 0.80
      ''}

      -- Keybindings for word navigation (Ctrl+Arrows) and word deletion (Ctrl+Backspace / Ctrl+Delete)
      config.keys = {
        { key = 'LeftArrow', mods = 'CTRL', action = wezterm.action.SendString '\x1b[1;5D' },
        { key = 'RightArrow', mods = 'CTRL', action = wezterm.action.SendString '\x1b[1;5C' },
        { key = 'Backspace', mods = 'CTRL', action = wezterm.action.SendString '\x08' },
        { key = 'Delete', mods = 'CTRL', action = wezterm.action.SendString '\x1b[3;5~' },
      }

      return config
    '';
  };
}

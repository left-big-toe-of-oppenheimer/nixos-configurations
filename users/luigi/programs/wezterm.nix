{ config, pkgs, ... }:

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

      -- Fully opaque solid background to eliminate background bleed-through and increase contrast
      config.window_background_opacity = 1.0

      -- High-contrast Tokyo Night color scheme matching Neovim
      config.color_scheme = 'Tokyo Night'

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

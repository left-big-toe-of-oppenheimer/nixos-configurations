{ config, pkgs, ... }:

{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()

      -- Increase default font size & window opacity
      config.font_size = 14.0
      config.window_background_opacity = 0.80

      -- Native WezTerm color scheme
      config.color_scheme = 'Catppuccin Mocha'

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

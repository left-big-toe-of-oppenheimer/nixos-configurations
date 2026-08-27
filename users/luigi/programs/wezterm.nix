{ config, pkgs, ... }:

{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()

      -- Increase default font size
      config.font_size = 14.0

      return config
    '';
  };
}

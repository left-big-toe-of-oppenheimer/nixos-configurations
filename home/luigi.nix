{ config, pkgs, ... }:

{
  home.username = "luigi";
  home.homeDirectory = "/home/luigi";

  # User-specific packages and dotfiles managed by Home Manager
  home.packages = with pkgs; [
    # Personal apps/tools can be placed here
  ];

  # Basic Git configuration managed via Home Manager
  programs.git = {
    enable = true;
    settings = {
      user.name = "luigi";
      user.email = "luigi@nixos.local";
    };
  };

  # WezTerm terminal configuration managed via Home Manager
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

  # Home Manager state version
  home.stateVersion = "26.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}

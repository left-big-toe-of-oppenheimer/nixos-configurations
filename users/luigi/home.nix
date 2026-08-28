{ config, pkgs, ... }:

{
  home.username = "luigi";
  home.homeDirectory = "/home/luigi";

  # User-specific packages and dotfiles managed by Home Manager
  home.packages = with pkgs; [
    # Personal apps/tools can be placed here
  ];

  imports = [
    ./programs
  ];

  # Home Manager state version
  home.stateVersion = "26.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}

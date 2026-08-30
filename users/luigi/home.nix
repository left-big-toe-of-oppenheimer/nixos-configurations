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

  # Session environment variables
  home.sessionVariables = {
    VIRTUAL_ENV = "/home/luigi/.global-env";
    LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib\${LD_LIBRARY_PATH:+:}\$LD_LIBRARY_PATH";
  };

  # Add custom scripts directory and global-env to PATH
  home.sessionPath = [
    "/etc/nixos/scripts"
    "/home/luigi/.global-env/bin"
  ];

  # Home Manager state version
  home.stateVersion = "26.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}

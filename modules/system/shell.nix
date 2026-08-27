{ config, lib, pkgs, ... }:

{
  # Enable Zsh globally so it can be set as the default login shell.
  # All user preferences, history, and syntax highlighting are managed in Home Manager (home/luigi.nix).
  programs.zsh.enable = true;
}

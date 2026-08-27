{ config, lib, pkgs, ... }:

{
  # -------------------------------------------------------------------------
  # Command-Line Tools & Terminal Utilities
  # -------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    vim
    wget
    bat
    ripgrep
    fd
    fzf
    eza
    btop
    procs
    rename
    tree
  ];

  # Enable Zsh globally so it can be set as the default login shell.
  programs.zsh.enable = true;
}

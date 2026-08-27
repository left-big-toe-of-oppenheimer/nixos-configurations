{ config, lib, pkgs, ... }:

{
  # -------------------------------------------------------------------------
  # Command-Line Tools & Terminal Utilities
  # -------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    vim
    wget
    ripgrep
    fd
    fzf
    eza
    btop
    procs
    rename
    tree
  ];
}

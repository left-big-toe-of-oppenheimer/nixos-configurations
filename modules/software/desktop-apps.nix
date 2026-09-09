{ config, lib, pkgs, ... }:

{
  # -------------------------------------------------------------------------
  # Desktop GUI Applications & Wayland Utilities
  # -------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    mpv
    kdePackages.kcalc
    kdePackages.falkon
    wofi
    wl-clipboard          # Wayland clipboard helper

    localsend
  ];
}

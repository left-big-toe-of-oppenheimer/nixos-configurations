{ config, lib, pkgs, ... }:

{
  # -------------------------------------------------------------------------
  # Desktop GUI Applications & Wayland Utilities
  # -------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    mpv
    kdePackages.falkon
    wofi
    wl-clipboard          # Wayland clipboard helper
    kdePackages.bluedevil   # KDE Plasma Bluetooth tray applet
  ];
}

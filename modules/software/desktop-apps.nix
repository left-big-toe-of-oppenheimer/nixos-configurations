{ config, lib, pkgs, ... }:

{
  # -------------------------------------------------------------------------
  # Desktop GUI Applications & Wayland Utilities
  # -------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    mpv
    kdePackages.kcalc
    kdePackages.falkon
    kdePackages.spectacle   # KDE Screenshot & OCR text extraction tool
    wofi
    wl-clipboard          # Wayland clipboard helper
    kdePackages.bluedevil   # KDE Plasma Bluetooth tray applet
  ];
}

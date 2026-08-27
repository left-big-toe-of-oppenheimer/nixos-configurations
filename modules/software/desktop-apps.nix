{ config, lib, pkgs, ... }:

{
  # -------------------------------------------------------------------------
  # Desktop GUI Applications & Wayland Utilities
  # -------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    firefox
    kdePackages.falkon
    wezterm
    wofi
    wl-clipboard          # Wayland clipboard helper
    kdePackages.bluedevil   # KDE Plasma Bluetooth tray applet
  ];

  programs.firefox.enable = true;
}

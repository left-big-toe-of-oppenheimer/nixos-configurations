{ config, lib, pkgs, ... }:

{
  # --- Display manager ---
  services.displayManager.sddm = {
    enable = true;
    # wayland.enable = true;   # uncomment when dropping Plasma
  };

  # --- Desktop environments ---
  services.desktopManager.plasma6.enable = true;   # current daily driver
  programs.hyprland.enable = true;                  # available at login screen
}

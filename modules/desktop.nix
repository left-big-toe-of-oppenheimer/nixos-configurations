{ config, lib, pkgs, ... }:

# Long-term goal: drop Plasma and run a minimal Hyprland setup.
# Both are wired up here so you can test Hyprland sessions from SDDM
# without committing to the switch yet.
#
# When ready to go Hyprland-only:
#   1. Set desktopManager.plasma6.enable = false
#   2. Enable sddm.wayland.enable = true
#   3. Move packages from environment.systemPackages to a hyprland.nix module

{
  # --- Display manager ---
  services.displayManager.sddm = {
    enable = true;
    # wayland.enable = true;   # uncomment when dropping Plasma
  };

  # --- Desktop environments ---
  services.desktopManager.plasma6.enable = true;   # current daily driver
  programs.hyprland.enable = true;                  # available at login screen already

  # --- GPU ---
  hardware = {
    graphics.enable             = true;
    nvidia.modesetting.enable   = true;
  };

  # --- Input ---
  services.libinput.enable = true;

  # --- Printing ---
  services.printing.enable = true;
}

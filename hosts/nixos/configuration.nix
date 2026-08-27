{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./hardware-configuration.nix

    # System & Hardware modules
    ../../modules/system/boot.nix
    ../../modules/system/hardware.nix
    ../../modules/system/locale.nix
    ../../modules/system/networking.nix
    ../../modules/system/audio.nix

    # Desktop Environment
    ../../modules/desktop/desktop.nix

    # Software scopes
    ../../modules/software/cli-tools.nix
    ../../modules/software/desktop-apps.nix
    ../../modules/software/dev-tools.nix
    ../../modules/software/services.nix

    # User accounts
    ../../users/luigi/system.nix
  ];

  # Enable Nix experimental features for Flakes support
  nix.settings.experimental-features = [ 
    "nix-command" 
    "flakes"
  ];

  # DO NOT change stateVersion after initial install.
  system.stateVersion = "26.05";
}

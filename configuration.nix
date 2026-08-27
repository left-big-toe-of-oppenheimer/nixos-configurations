{ config, lib, pkgs, ... }:

  # Minimal non-damaging edit test

{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./hardware-configuration.nix

    # System modules
    ./modules/boot.nix
    ./modules/locale.nix
    ./modules/networking.nix
    ./modules/audio.nix
    ./modules/desktop.nix
    ./modules/shell.nix
    ./modules/users.nix
    ./modules/services.nix
  ];

  # -------------------------------------------------------------------------
  # System packages
  # Prefer putting user-specific packages inside users.nix or home-manager.
  # -------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    vim
    wget
    wezterm
    wofi
    git
    lynx
    kdePackages.falkon  #    falkon
    ripgrep
    fd
    fzf
    eza
    btop
    procs
    (python3.withPackages (ps: [ ps.pypdf ]))
    claude-code
    wl-clipboard        # Command-line copy/paste utilities for Wayland
    kdePackages.bluedevil # KDE Plasma Bluetooth GUI/tray applet (Plasma 6)
    rename
    antigravity
  ];

  
  programs.firefox.enable = true;

  # -------------------------------------------------------------------------
  # DO NOT change stateVersion after the initial install.
  # It pins internal data-format compatibility, not the NixOS release itself.
  # -------------------------------------------------------------------------
  nix.settings.experimental-features = [ 
	"nix-command" 
	"flakes"
 ];

  
  system.stateVersion = "26.05";
}

{ config, lib, pkgs, ... }:

{
  networking = {
    hostName = "nixos";

    networkmanager = {
      enable = true;
      ensureProfiles = {
        environmentFiles = [ ];
        profiles = {};
      };
    };

    # Firewall — locked down by default; open ports as needed.
    firewall = {
      enable = true;
      # allowedTCPPorts = [ 22 80 443 ];
    };
  };
}

{ config, lib, pkgs, ... }:

{
  

  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = false;   # key-only; safer default
      PermitRootLogin        = "no";
    };
  };

  # Firewall — locked down by default; open ports as needed.
  networking.firewall = {
    enable = true;
    # allowedTCPPorts = [ 22 80 443 ];
  };
}

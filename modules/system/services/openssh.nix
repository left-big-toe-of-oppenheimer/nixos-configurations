{ config, lib, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;   # key-only; safer default
      PermitRootLogin        = "no";
    };
  };
}

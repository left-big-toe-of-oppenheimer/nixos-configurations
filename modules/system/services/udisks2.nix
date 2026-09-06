{ config, lib, pkgs, ... }:

{
  services.udisks2 = {
    enable = true;
    # Add your system service configuration here
  };
}

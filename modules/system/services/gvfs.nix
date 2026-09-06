{ config, lib, pkgs, ... }:

{
  services.gvfs = {
    enable = true;
    # Add your system service configuration here
  };
}

{ config, lib, pkgs, ... }:

{
  # --- GPU & Graphics ---
  hardware = {
    graphics.enable           = true;
    nvidia.modesetting.enable = true;
  };

  # --- Input Devices ---
  services.libinput.enable = true;

  # --- Printing ---
  services.printing.enable = true;
}

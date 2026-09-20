{ config, lib, pkgs, ... }:

{
  # --- GPU & Graphics ---
  hardware = {
    graphics.enable           = true;
    nvidia = {
      modesetting.enable = true;
#     powerManagement.enable = false;
      open = false; # Use the closed-source driver
      nvidiaSettings = true;

      # Configure Optimus PRIME
      prime = {
        sync.enable = true; # Sync mode forces the NVIDIA GPU on, activating the HDMI port
        
        # Replace these with your actual Bus IDs from Step 1
        intelBusId = "PCI:0:2:0"; 
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  }; # <--- MANCAVA QUESTA CHIUSURA

  # Load proprietary NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];  

  # --- Input Devices ---
  services.libinput.enable = true;

  # --- Printing ---
  services.printing.enable = true;
}

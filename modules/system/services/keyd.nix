{ config, lib, pkgs, ... }:

{
  services.keyd = {
    enable = true;
    
    # Crea il file /etc/keyd/default.conf
    keyboards.default = {
      ids = [ "*" ]; # Applica a tutte le tastiere connesse
      
      settings = {
        main = {
          # Trasforma Caps Lock in un toggle per il layer 'caps_active'
          capslock = "toggle(caps_active)";

          # Shift+tasto come azione predefinita (default action)
          "1" = "S-1";
          "2" = "S-2";
          "3" = "S-3";
          "4" = "S-4";
          "5" = "S-5";
          "6" = "S-6";
          "7" = "S-7";
          "8" = "S-8";
          "9" = "S-9";
          "0" = "S-0";
        };

        # Definizione del layer attivo con Caps Lock
        caps_active = {
          # Premere di nuovo Caps Lock disattiva il layer
          capslock = "toggle(caps_active)";

          # Numeri come conseguenza del Caps Lock attivo
          "1" = "1";
          "2" = "2";
          "3" = "3";
          "4" = "4";
          "5" = "5";
          "6" = "6";
          "7" = "7";
          "8" = "8";
          "9" = "9";
          "0" = "0";
        };
      };
    };
  };
}

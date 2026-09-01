{ config, lib, pkgs, ... }:

{
  services.keyd = {
    enable = true;
    
    # Crea il file /etc/keyd/default.conf
    keyboards.default = {
      ids = [ "*" ]; # Applica a tutte le tastiere connesse
      
      settings = {
        global = {
          layer_indicator = 1;
        };

        main = {
          # Trasforma Caps Lock in toggle per il Caps Lock di sistema (lettere maiuscole) e per il layer 'caps_active'
          capslock = "togglem(caps_active, capslock)";

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

        # Quando si tiene premuto Shift (senza Caps Lock attivo)
        # Shift inverte il comportamento predefinito e produce i numeri
        shift = {
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

        # Definizione del layer attivo con Caps Lock
        caps_active = {
          # Premere di nuovo Caps Lock disattiva il Caps Lock di sistema e il layer
          capslock = "togglem(caps_active, capslock)";

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

        # Quando Caps Lock è attivo e si tiene premuto anche Shift
        # Shift inverte temporaneamente Caps Lock e produce Shift+tasto
        "caps_active+shift" = {
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
      };
    };
  };
}

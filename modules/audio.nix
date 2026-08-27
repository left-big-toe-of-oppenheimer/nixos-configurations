{ config, lib, pkgs, ... }:

{
  services.pipewire = {
    enable       = true;
    pulse.enable = true;    # PulseAudio compatibility shim
    # alsa.enable       = true;   # uncomment if you need raw ALSA
    # jack.enable       = true;   # uncomment for JACK support
  };
}

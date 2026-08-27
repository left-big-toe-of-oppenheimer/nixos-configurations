{ config, lib, pkgs, ... }:

{
  users.users.luigi = {
    isNormalUser = true;
    shell        = pkgs.zsh;

    extraGroups  = [
      "wheel"           # sudo
      "networkmanager"  # manage WiFi without sudo
      "video"           # GPU / brightness control
      "audio"           # direct audio device access
    ];
  };
}

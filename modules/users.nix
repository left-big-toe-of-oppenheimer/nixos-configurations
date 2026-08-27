{ config, lib, pkgs, ... }:

{
  users.users.luigi = {
    isNormalUser = true;
    shell        = pkgs.zsh;         # use zsh defined in shell.nix

    extraGroups  = [
      "wheel"           # sudo
      "networkmanager"  # manage WiFi without sudo
      "video"           # GPU / brightness control
      "audio"           # direct audio device access (usually not needed with pipewire)
    ];

    packages = with pkgs; [
      tree
    ];
  };
}

{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "luigi";
      user.email = "luigi@nixos.local";
    };
  };
}

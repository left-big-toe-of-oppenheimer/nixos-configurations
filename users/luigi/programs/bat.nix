{ config, pkgs, ... }:

let
  theme = import ../theme.nix { inherit (pkgs) lib; };
in
{
  programs.bat = {
    enable = true;
    config = {
      theme = "${theme.bat.theme}";
    };
  };
}

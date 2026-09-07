{ config, pkgs, ... }:

let
  theme = import ../theme.nix;
in
{
  programs.bat = {
    enable = true;
    config = {
      theme = if theme == "tokyonight" then "TwoDark" else "Catppuccin Mocha";
    };
  };
}

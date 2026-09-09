{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.mdcat
  ];
}

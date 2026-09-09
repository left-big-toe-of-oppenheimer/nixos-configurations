{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.localsend
  ];
}

{ config, lib, pkgs, ... }:

{
  time.timeZone = "Europe/Rome";

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font   = "Lat2-Terminus16";
    keyMap = "it";
  };
}

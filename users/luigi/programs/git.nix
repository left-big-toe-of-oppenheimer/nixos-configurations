{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = " left-big-toe-of-oppenheimer ";
      user.email = "dellemo.tech@gmail.com";
    };
  };
}

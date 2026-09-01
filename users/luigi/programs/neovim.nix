{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;

    initLua = ''
      require("config.lazy")
    '';
  };

  # Symlink LazyVim configuration files from /etc/nixos into ~/.config/nvim/lua
  xdg.configFile."nvim/lua".source = ./nvim/lua;
}

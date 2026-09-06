{ pkgs, ... }:

let
  theme = import ../theme.nix { inherit (pkgs) lib; };
in
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

  # Symlink LazyVim configuration structure into ~/.config/nvim/lua
  xdg.configFile."nvim/lua/config".source = ./nvim/lua/config;
  xdg.configFile."nvim/lua/plugins/example.lua".source = ./nvim/lua/plugins/example.lua;
  xdg.configFile."nvim/lua/plugins/lang.lua".source = ./nvim/lua/plugins/lang.lua;
  xdg.configFile."nvim/lua/plugins/lsp.lua".source = ./nvim/lua/plugins/lsp.lua;
  xdg.configFile."nvim/lua/plugins/theme.lua".text = theme.neovim.themePlugin;
}

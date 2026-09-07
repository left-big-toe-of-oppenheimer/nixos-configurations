{ pkgs, ... }:

let
  theme = import ../theme.nix;
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
      vim.g.theme_style = "${theme}"
      require("config.lazy")
    '';
  };

  # Standard static directory symlink
  xdg.configFile."nvim/lua".source = ./nvim/lua;
}

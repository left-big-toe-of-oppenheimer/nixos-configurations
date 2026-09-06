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

  # Symlink LazyVim configuration directory with the active theme from theme.nix
  xdg.configFile."nvim/lua".source = pkgs.runCommand "nvim-lua-config" {} ''
    mkdir -p $out
    cp -r ${./nvim/lua}/* $out/
    chmod -R u+w $out
    cat << 'EOF' > $out/plugins/theme.lua
${theme.neovim.themePlugin}
EOF
  '';
}

{ config, pkgs, ... }:

{
  home.username = "luigi";
  home.homeDirectory = "/home/luigi";

  # User-specific packages and dotfiles managed by Home Manager
  home.packages = with pkgs; [
    # Personal apps/tools can be placed here
  ];

  # Basic Git configuration managed via Home Manager
  programs.git = {
    enable = true;
    settings = {
      user.name = "luigi";
      user.email = "luigi@nixos.local";
    };
  };

  # WezTerm terminal configuration managed via Home Manager
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()

      -- Increase default font size
      config.font_size = 14.0

      return config
    '';
  };

  # Zsh terminal environment managed via Home Manager
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Elegant history management
    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      share = true;
    };

    # Custom aliases
    shellAliases = {
      cl = "clear";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos";
    };

    # Pure zshrc initialization
    initContent = ''
      # Directory shortcuts
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS

      # Completion tweaks
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

      # Keybindings: Alt+Left / Alt+Right for word navigation
      bindkey "^[[1;3C" forward-word
      bindkey "^[[1;3D" backward-word
      bindkey "^[f" forward-word
      bindkey "^[b" backward-word
    '';
  };

  # Home Manager state version
  home.stateVersion = "26.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}

{ config, pkgs, ... }:

{
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
      conf = "cd /etc/nixos/users/luigi";
      e0 = "echo \$0";
      add-program = "/etc/nixos/scripts/add-program.sh";
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
}

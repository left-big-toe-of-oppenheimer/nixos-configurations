{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    envExtra = ''
      export PATH="$HOME/.global-env/bin:$PATH"
      export VIRTUAL_ENV="$HOME/.global-env"
    '';



    # Elegant history management
    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      share = true;
    };

    # Oh My Zsh theme & plugin integration
    oh-my-zsh = {
      enable = true;
      theme = "random";
      plugins = [ "git" "sudo" "dirhistory" ];
      extraConfig = ''
        # Randomly select between floating cloud, lambda, and minimalist time tracking themes
        ZSH_THEME_RANDOM_CANDIDATES=( "cloud" "lambda" "fino-time" )
      '';
    };

    # Custom aliases
    shellAliases = {
      cl = "clear";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos";
      conf = "cd /etc/nixos/users/luigi";
      e0 = "echo \$0";
      open ="xdg-open";
      add-program = "add-program.sh";
      rm-program = "remove-program.sh";
      add-service = "add-service.sh";
      rm-service = "remove-service.sh";
      sync-python-env = "sync-python-env.sh";
    

      # Colored & Iconified directory listings
      ls = "eza --icons=auto --group-directories-first";
      l = "eza -l --icons=auto --group-directories-first";
      ll = "eza -la --icons=auto --group-directories-first";
      la = "eza -a --icons=auto --group-directories-first";
      tree = "eza --tree --icons=auto";
    };

    # Pure zshrc initialization
    initContent = ''
      # Directory shortcuts
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS

      # Colored output & completions
      eval "$(dircolors -b)" 2>/dev/null
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

      # Keybindings: Ctrl+Arrows for word navigation (Alt+Arrows reserved for dirhistory plugin)
      bindkey "^[[1;5D" backward-word
      bindkey "^[[1;5C" forward-word

      # Keybindings: Ctrl+Backspace & Ctrl+Delete/Canc for word deletion
      bindkey "^H"        backward-kill-word
      bindkey "^[[127;5u" backward-kill-word
      bindkey "^[[3;5~"   kill-word
      bindkey "^[[3~"     delete-char
    '';
  };
}

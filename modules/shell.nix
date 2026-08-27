{ config, lib, pkgs, ... }:

{
  # Make zsh the system-wide default shell.
  # Each user who wants it still needs `users.users.<name>.shell = pkgs.zsh`.
  programs.zsh = {
    enable = true;

    # Completion engine — makes Tab-completion fast and context-aware.
    enableCompletion = true;

    # Suggest the right package when you type an unknown command.
    # (requires nix-index to be installed; add it to packages if you want it)
    # enableAutosuggestions is user-level; wire it through home-manager or
    # the interactiveShellInit block below instead.

    autosuggestions.enable   = true;   # ghost-text suggestions from history
    syntaxHighlighting.enable = true;  # color-code commands as you type

    # A sane baseline prompt and history setup.
    # Replace with your own .zshrc / home-manager config as things grow.
    interactiveShellInit = ''
      # History
      HISTSIZE=10000
      SAVEHIST=10000
      setopt HIST_IGNORE_DUPS
      setopt SHARE_HISTORY

      # Directory shortcuts
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS

      # Completion tweaks
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'   # case-insensitive
    '';
  };
}

{ config, lib, pkgs, ... }:

{
  # -------------------------------------------------------------------------
  # Command-Line Tools & Terminal Utilities
  # -------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    # Core CLI & Unix utilities
    coreutils
    binutils
    curl
    wget
    unzip
    jq
    ripgrep
    fd
    tree
    diffutils
    patch

    # Terminal navigation, monitoring & editing
    vim
    fzf
    eza
    btop
    procs
    rename
    inotify-tools
    entr

    # OCR Language Models & Utilities
    (tesseract.override {
      enableLanguages = [ "eng" "ita" "osd" ];
    })
    libqalculate
  ];

  # Export TESSDATA_PREFIX so graphical apps like Spectacle find the OCR traineddata models
  environment.sessionVariables = {
    TESSDATA_PREFIX = "/run/current-system/sw/share/tessdata";
  };
  environment.variables = {
    TESSDATA_PREFIX = "/run/current-system/sw/share/tessdata";
  };

  # Enable Zsh globally so it can be set as the default login shell.
  programs.zsh.enable = true;
}

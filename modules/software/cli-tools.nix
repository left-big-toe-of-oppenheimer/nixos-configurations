{ config, lib, pkgs, ... }:

let
  tesseractWithLangs = pkgs.tesseract.override {
    enableLanguages = [ "eng" "ita" "osd" ];
  };

  pacnix = pkgs.writeScriptBin "pacnix" ''
    #!${pkgs.python3}/bin/python3
    ${builtins.readFile ../../refactoring/pacnix.py}
  '';
in
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
    git
    unzip
    jq
    ripgrep
    fd
    tree
    diffutils
    patch

    # Database-driven NixOS manager & registry CLI
    pacnix

    # Terminal navigation, monitoring & tools
    fzf
    eza
    btop
    procs
    rename
    inotify-tools
    entr

    # OCR Language Models & Utilities
    tesseractWithLangs
    libqalculate
  ];

  # Export TESSDATA_PREFIX so graphical apps like Spectacle find the OCR traineddata models
  environment.sessionVariables = {
    TESSDATA_PREFIX = "${tesseractWithLangs}/share/tessdata";
  };

  # Enable Zsh globally so it can be set as the default login shell.
  programs.zsh.enable = true;
}

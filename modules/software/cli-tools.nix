{ config, lib, pkgs, ... }:

let
  tesseractWithLangs = pkgs.tesseract.override {
    enableLanguages = [ "eng" "ita" "osd" ];
  };
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

    ffmpeg
    libheif	# To Convert HEIF file to jpg and others
    
    # markdown editors & visualizers
    glow
    mdcat

    # usb mangement
    usbutils


    # epub to kepub conversion
    (stdenv.mkDerivation rec {
    pname = "kepubify";
    version = "4.0.4";

    src = fetchurl {
      url = "https://github.com/pgaskin/kepubify/releases/download/v${version}/kepubify-linux-64bit";
      hash = "sha256-N9dijSbFyQb2B/JLNveB8wYHXnBzpv54IKdRu2BDH8U=";

    };

    dontUnpack = true;

    installPhase = ''
      install -D -m 755 $src $out/bin/kepubify
    '';
  })

  # typst setup 
  typst
  tinymist
  typstyle

  ];

  # Export TESSDATA_PREFIX so graphical apps like Spectacle find the OCR traineddata models
  environment.sessionVariables = {
    TESSDATA_PREFIX = "${tesseractWithLangs}/share/tessdata";
  };

  # Enable Zsh globally so it can be set as the default login shell.
  programs.zsh.enable = true;
}

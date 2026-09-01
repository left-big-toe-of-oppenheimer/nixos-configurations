{ config, lib, pkgs, ... }:

{
  # -------------------------------------------------------------------------
  # Development Tools & Scripting Runtimes
  # -------------------------------------------------------------------------
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    # AI & Nix Language Tooling
    nil                 # Nix Language Server
    claude-code
    antigravity-cli

    # Core build & C/C++ toolchain
    gcc
    clang
    gnumake
    cmake
    ninja
    pkg-config
    tree-sitter
    gdb
    valgrind

    # Version control (git is managed via Home Manager in users/luigi/programs/git.nix)
    gh

    # Standard runtimes
    (python3.withPackages (ps: with ps; [
      pypdf
      requests
      pandas
      numpy
      rich
      pillow
    ]))
    nodejs
    rustc
    cargo
  ];
}

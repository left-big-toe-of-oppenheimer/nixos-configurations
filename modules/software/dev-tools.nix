{ config, lib, pkgs, ... }:

{
  # -------------------------------------------------------------------------
  # Development Tools & Scripting Runtimes
  # -------------------------------------------------------------------------
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    nil                 # Nix Language Server
    (python3.withPackages (ps: [ ps.pypdf ]))
    claude-code
    antigravity-cli
  ];
}

{ config, lib, pkgs, ... }:

{
  # -------------------------------------------------------------------------
  # Development Tools & Scripting Runtimes
  # -------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    nil                 # Nix Language Server
    (python3.withPackages (ps: [ ps.pypdf ]))
    claude-code
    antigravity-ide
  ];
}

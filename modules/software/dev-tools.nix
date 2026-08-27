{ config, lib, pkgs, ... }:

{
  # -------------------------------------------------------------------------
  # Development Tools & Scripting Runtimes
  # -------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    (python3.withPackages (ps: [ ps.pypdf ]))
    claude-code
    antigravity-ide
  ];
}

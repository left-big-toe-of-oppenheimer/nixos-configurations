#!/usr/bin/env bash
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: add-program <program-name>"
  exit 1
fi

PROGRAM="$1"
TARGET="/etc/nixos/users/luigi/programs/$PROGRAM.nix"

if [ -f "$TARGET" ]; then
  echo "Error: $TARGET already exists!"
  exit 1
fi

cat << NIX > "$TARGET"
{ config, pkgs, ... }:

{
  programs.$PROGRAM = {
    enable = true;
  };
}
NIX

chmod 644 "$TARGET"
git -C /etc/nixos add "$TARGET"
echo "Created $TARGET"
echo "You can now edit it if needed, then run 'rebuild' to apply."

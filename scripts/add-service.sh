#!/usr/bin/env bash
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: add-service <service-name>"
  exit 1
fi

SERVICE="$1"
TARGET="/etc/nixos/modules/system/services/$SERVICE.nix"

if [ -f "$TARGET" ]; then
  echo "Error: $TARGET already exists!"
  exit 1
fi

cat << NIX > "$TARGET"
{ config, lib, pkgs, ... }:

{
  services.$SERVICE = {
    enable = true;
  };
}
NIX

chmod 644 "$TARGET"
git -C /etc/nixos add "$TARGET"
echo "Created $TARGET"
echo "You can now edit it if needed, then run 'rebuild' to apply."

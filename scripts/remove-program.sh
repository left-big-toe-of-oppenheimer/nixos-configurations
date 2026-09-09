#!/usr/bin/env bash
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: rm-program <program-name>"
  exit 1
fi

PROGRAM="$1"
TARGET="/etc/nixos/users/luigi/programs/$PROGRAM.nix"

if [ ! -f "$TARGET" ]; then
  echo "Error: $TARGET does not exist!"
  exit 1
fi

git -C /etc/nixos rm -f "$TARGET"
echo "Removed $TARGET"
echo "Run 'rebuild' to apply changes to your live system."

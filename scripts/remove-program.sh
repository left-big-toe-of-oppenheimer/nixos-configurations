#!/usr/bin/env bash
# remove-program.sh
# Automatically removes a Home Manager program configuration and cleans the registry

if [ -z "$1" ]; then
  echo "Usage: ./remove-program.sh <program-name>"
  exit 1
fi

PROGRAM="$1"
DIR="/etc/nixos/users/luigi/programs"
TARGET_FILE="$DIR/$PROGRAM.nix"
DEFAULT_FILE="$DIR/default.nix"

# 1. Remove the file
if [ -f "$TARGET_FILE" ]; then
  rm "$TARGET_FILE"
  echo "Removed $TARGET_FILE"
else
  echo "Warning: $TARGET_FILE does not exist, skipping file deletion."
fi

# 2. Remove it from the default.nix import list
# We use sed to delete the line containing exactly "./$PROGRAM.nix"
sed -i "\\|./$PROGRAM.nix|d" "$DEFAULT_FILE"
echo "Removed ./$PROGRAM.nix from $DEFAULT_FILE"

# 3. Track in Git
cd /etc/nixos || exit 1
git add "$DEFAULT_FILE"
# If the file was tracked and we deleted it, git rm will stage the deletion
git rm -q --ignore-unmatch "$TARGET_FILE"
git commit -m "refactor(home): remove $PROGRAM"

echo "Done! Run 'rebuild' to apply the removal to your live system."

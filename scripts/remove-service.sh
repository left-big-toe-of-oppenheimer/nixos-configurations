#!/usr/bin/env bash
# remove-service.sh
# Automatically removes a System Service configuration

if [ -z "$1" ]; then
  echo "Usage: rm-service <service-name>"
  exit 1
fi

SERVICE="$1"
DIR="/etc/nixos/modules/system/services"
TARGET_FILE="$DIR/$SERVICE.nix"
DEFAULT_FILE="$DIR/default.nix"

# 1. Remove the file
if [ -f "$TARGET_FILE" ]; then
  rm "$TARGET_FILE"
  echo "Removed $TARGET_FILE"
else
  echo "Warning: $TARGET_FILE does not exist, skipping file deletion."
fi

# 2. Remove it from the default.nix import list
sed -i "\\|./$SERVICE.nix|d" "$DEFAULT_FILE"
echo "Removed ./$SERVICE.nix from $DEFAULT_FILE"

# 3. Track in Git
cd /etc/nixos || exit 1
git add "$DEFAULT_FILE"
git rm -q --ignore-unmatch "$TARGET_FILE"
git commit -m "refactor(system): remove $SERVICE service"

echo "Done! Run 'rebuild' to apply the removal to your live system."

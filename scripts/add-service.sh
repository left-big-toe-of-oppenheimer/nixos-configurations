#!/usr/bin/env bash
# add-service.sh
# Automatically scaffolds a new System Service configuration

if [ -z "$1" ]; then
  echo "Usage: add-service <service-name>"
  exit 1
fi

SERVICE="$1"
DIR="/etc/nixos/modules/system/services"
TARGET_FILE="$DIR/$SERVICE.nix"
DEFAULT_FILE="$DIR/default.nix"

# 1. Create the template file if it doesn't exist
if [ -f "$TARGET_FILE" ]; then
  echo "Error: $TARGET_FILE already exists!"
  exit 1
fi

cat <<EOF > "$TARGET_FILE"
{ config, lib, pkgs, ... }:

{
  services.$SERVICE = {
    enable = true;
    # Add your system service configuration here
  };
}
EOF

echo "Created $TARGET_FILE"

# 2. Add it to the default.nix import list
sed -i "/  ];/i \\    ./$SERVICE.nix" "$DEFAULT_FILE"

echo "Added ./$SERVICE.nix to $DEFAULT_FILE"

# 3. Track in Git
cd /etc/nixos || exit 1
git add "$TARGET_FILE" "$DEFAULT_FILE"
git commit -m "feat(system): auto-scaffold $SERVICE service"

echo "Done! You can now edit $TARGET_FILE and run 'rebuild' when ready."

#!/usr/bin/env bash
# add-program.sh
# Automatically scaffolds a new Home Manager program configuration

if [ -z "$1" ]; then
  echo "Usage: ./add-program.sh <program-name>"
  exit 1
fi

PROGRAM="$1"
DIR="/etc/nixos/users/luigi/programs"
TARGET_FILE="$DIR/$PROGRAM.nix"
DEFAULT_FILE="$DIR/default.nix"

# 1. Create the template file if it doesn't exist
if [ -f "$TARGET_FILE" ]; then
  echo "Error: $TARGET_FILE already exists!"
  exit 1
fi

cat <<EOF > "$TARGET_FILE"
{ config, pkgs, ... }:

{
  programs.$PROGRAM = {
    enable = true;
    # Add your configuration here
  };
}
EOF

echo "Created $TARGET_FILE"

# 2. Add it to the default.nix import list
# We use sed to insert "    ./$PROGRAM.nix" right before the closing "  ];" line
sed -i "/  ];/i \\    ./$PROGRAM.nix" "$DEFAULT_FILE"

echo "Added ./$PROGRAM.nix to $DEFAULT_FILE"

# 3. Automatic Deduplication from System Packages
# If the program was previously installed globally, remove it to prevent duplicates
for file in /etc/nixos/modules/software/*.nix; do
  if grep -qE "^[[:space:]]+$PROGRAM([[:space:]]+.*)?$" "$file"; then
    sed -i -E "/^[[:space:]]+$PROGRAM([[:space:]]+.*)?$/d" "$file"
    echo "Automagic: Removed duplicate '$PROGRAM' from $file"
    git add "$file"
  fi
done

# 4. Track in Git
cd /etc/nixos || exit 1
git add "$TARGET_FILE" "$DEFAULT_FILE"
git commit -m "feat(home): auto-scaffold $PROGRAM"

echo "Done! You can now edit $TARGET_FILE and run 'rebuild' when ready."

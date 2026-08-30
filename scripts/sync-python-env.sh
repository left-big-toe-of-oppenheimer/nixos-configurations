#!/usr/bin/env bash
# sync-python-env.sh
# Synchronizes the global Python virtual environment (~/.global-env)
# with dependencies declared in ~/.config/python/pyproject.toml using uv.

set -euo pipefail

ENV_DIR="${HOME}/.global-env"
CONFIG_FILE="${HOME}/.config/python/pyproject.toml"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "[!] Config file not found at: $CONFIG_FILE"
  exit 1
fi

echo "[*] Ensuring global virtualenv at $ENV_DIR..."
if [ ! -d "$ENV_DIR" ] || [ ! -f "$ENV_DIR/pyvenv.cfg" ]; then
  uv venv "$ENV_DIR" --python python3
fi

# Ensure compatibility symlink ~/.global-venv -> ~/.global-env
if [ ! -L "${HOME}/.global-venv" ]; then
  ln -sfn "$ENV_DIR" "${HOME}/.global-venv"
fi

echo "[*] Compiling and syncing dependencies from $CONFIG_FILE..."
uv pip sync --python "$ENV_DIR/bin/python" <(uv pip compile "$CONFIG_FILE")

echo "[✓] Global Python environment synchronized successfully!"
"$ENV_DIR/bin/python" -c "import requests; print(f'Python: {requests.__file__}')"

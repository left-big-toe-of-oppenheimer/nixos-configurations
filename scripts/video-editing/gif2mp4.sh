#!/usr/bin/env nix-shell
#!nix-shell -i bash -p ffmpeg

set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <input.gif> [output.mp4]" >&2
  exit 1
fi

INPUT="$1"
OUTPUT="${2:-${INPUT%.*}.mp4}"

if [ ! -f "$INPUT" ]; then
  echo "Error: File '$INPUT' not found." >&2
  exit 1
fi

ffmpeg -i "$INPUT" \
  -movflags faststart \
  -pix_fmt yuv420p \
  -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
  "$OUTPUT"

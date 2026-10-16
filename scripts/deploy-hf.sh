#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
export PATH="${HOME}/.local/bin:${PATH}"

SPACE_ID="${HF_SPACE_ID:-TonyGooF/ai-tool-map}"

if ! command -v hf >/dev/null 2>&1; then
  echo "hf CLI not found. Install: curl -LsSf https://hf.co/cli/install.sh | bash"
  exit 1
fi

if ! hf auth whoami >/dev/null 2>&1; then
  echo "Not logged in. Run: hf auth login   OR   export HF_TOKEN=hf_..."
  exit 1
fi

hf repos create "$SPACE_ID" --type space --space-sdk static --public --exist-ok

# Exclude secrets, caches, venvs, scanner internals not needed for the static UI
hf upload "$SPACE_ID" . --type space \
  --commit-message "Deploy AI Tool Map static site" \
  --exclude ".env*" \
  --exclude ".git*" \
  --exclude ".venv/**" \
  --exclude ".venv-hf/**" \
  --exclude "__pycache__/**" \
  --exclude "data/scan_cache/**" \
  --exclude ".hf-cli/**" \
  --exclude "scripts/**" \
  --exclude "*.pyc"

echo "Done."
echo "Space: https://huggingface.co/spaces/${SPACE_ID}"
# static URL pattern: lowercase owner-space
owner="${SPACE_ID%%/*}"
name="${SPACE_ID##*/}"
slug="$(echo "${owner}-${name}" | tr '[:upper:]' '[:lower:]')"
echo "App:   https://${slug}.hf.space"

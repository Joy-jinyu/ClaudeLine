#!/usr/bin/env bash

set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
SETTINGS_FILE="${CLAUDE_DIR}/settings.json"

if [ ! -f "$SETTINGS_FILE" ]; then
  echo "No ~/.claude/settings.json found."
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "ClaudeLine uninstall requires jq to edit ~/.claude/settings.json safely." >&2
  exit 1
fi

TMP_FILE="$(mktemp)"
jq 'del(.statusLine)' "$SETTINGS_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$SETTINGS_FILE"

echo "ClaudeLine uninstalled from ~/.claude/settings.json"


#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
SETTINGS_FILE="${CLAUDE_DIR}/settings.json"
BACKUP_FILE="${CLAUDE_DIR}/settings.json.bak.claudeline.$(date '+%Y%m%d_%H%M%S')"
MODE="${1:-normal}"

mkdir -p "$CLAUDE_DIR"

TARGET_COMMAND="${SCRIPT_DIR}/statusline.sh"
if [ "$MODE" = "--debug" ]; then
  TARGET_COMMAND="${SCRIPT_DIR}/statusline-debug.sh"
fi

chmod +x "${SCRIPT_DIR}/statusline.sh" "${SCRIPT_DIR}/statusline-debug.sh"

if [ -f "$SETTINGS_FILE" ]; then
  cp "$SETTINGS_FILE" "$BACKUP_FILE"
fi

if command -v jq >/dev/null 2>&1; then
  if [ -f "$SETTINGS_FILE" ]; then
    TMP_FILE="$(mktemp)"
    jq --arg cmd "$TARGET_COMMAND" '
      .statusLine = {
        "type": "command",
        "command": $cmd,
        "padding": 0
      }
    ' "$SETTINGS_FILE" > "$TMP_FILE"
    mv "$TMP_FILE" "$SETTINGS_FILE"
  else
    jq -n --arg cmd "$TARGET_COMMAND" '{
      statusLine: {
        type: "command",
        command: $cmd,
        padding: 0
      }
    }' > "$SETTINGS_FILE"
  fi
else
  echo "ClaudeLine install requires jq to edit ~/.claude/settings.json safely." >&2
  exit 1
fi

echo "ClaudeLine installed."
echo "statusLine command -> $TARGET_COMMAND"
if [ -f "$BACKUP_FILE" ]; then
  echo "backup -> $BACKUP_FILE"
fi


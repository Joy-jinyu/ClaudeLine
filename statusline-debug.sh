#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="${HOME}/.claude/logs"
LOG_FILE="${LOG_DIR}/claudeline-statusline-input.log"
RENDERER="${SCRIPT_DIR}/statusline.sh"

mkdir -p "$LOG_DIR"

INPUT=""
if [ ! -t 0 ]; then
  INPUT="$(cat 2>/dev/null || true)"
fi

{
  printf '[%s] statusLine payload\n' "$(date '+%Y-%m-%d %H:%M:%S')"
  if [ -n "$INPUT" ]; then
    printf '%s\n' "$INPUT"
  else
    printf '<empty>\n'
  fi
  printf '\n'
} >> "$LOG_FILE"

if [ -x "$RENDERER" ]; then
  printf '%s' "$INPUT" | "$RENDERER"
fi


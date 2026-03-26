#!/usr/bin/env bash

set -u

# Claude Code calls this command for statusLine and passes a JSON payload on
# stdin. ClaudeLine reads that payload and renders a compact, colorful
# two-line status bar.

INPUT=""
if [ ! -t 0 ]; then
  INPUT="$(cat 2>/dev/null || true)"
fi

has_jq=0
if command -v jq >/dev/null 2>&1; then
  has_jq=1
fi

if [ "${NO_COLOR:-0}" != "1" ]; then
  C_RESET=$'\033[0m'
  C_TITLE=$'\033[5;1;95m'
  C_MODEL=$'\033[1;96m'
  C_DIR=$'\033[1;92m'
  C_GIT=$'\033[1;94m'
  C_CTX=$'\033[1;95m'
  C_SESSION=$'\033[1;93m'
  C_STYLE=$'\033[1;36m'
  C_COST=$'\033[1;33m'
  C_SEP=$'\033[2;37m'
else
  C_RESET=""
  C_TITLE=""
  C_MODEL=""
  C_DIR=""
  C_GIT=""
  C_CTX=""
  C_SESSION=""
  C_STYLE=""
  C_COST=""
  C_SEP=""
fi

TITLE_PREFIX="${CLAUDELINE_TITLE_PREFIX:-英俊潇洒的}"
DEFAULT_NAME="${CLAUDELINE_DEFAULT_NAME:-锦逸}"

json_get() {
  local expr="$1"
  if [ "$has_jq" -eq 1 ] && [ -n "$INPUT" ]; then
    printf '%s' "$INPUT" | jq -r "$expr // empty" 2>/dev/null || true
  fi
}

format_k() {
  local value="${1:-0}"
  if [ -z "$value" ] || [ "$value" = "null" ]; then
    value=0
  fi

  if [ "$value" -ge 1000000 ] 2>/dev/null; then
    awk -v n="$value" 'BEGIN { printf "%.1fm", n / 1000000 }'
  elif [ "$value" -ge 1000 ] 2>/dev/null; then
    awk -v n="$value" 'BEGIN { printf "%.1fk", n / 1000 }'
  else
    printf '%s' "$value"
  fi
}

detect_model_display_name() {
  local raw="$1"
  if [ -z "$raw" ]; then
    return 0
  fi

  case "$raw" in
    claude-opus-*)
      printf 'Opus %s' "$(printf '%s' "$raw" | sed -E 's/^claude-opus-([0-9]+)-([0-9]+).*$/\1.\2/')"
      ;;
    claude-sonnet-*)
      printf 'Sonnet %s' "$(printf '%s' "$raw" | sed -E 's/^claude-sonnet-([0-9]+)-([0-9]+).*$/\1.\2/')"
      ;;
    claude-haiku-*)
      printf 'Haiku %s' "$(printf '%s' "$raw" | sed -E 's/^claude-haiku-([0-9]+)-([0-9]+).*$/\1.\2/')"
      ;;
    *)
      printf '%s' "$raw"
      ;;
  esac
}

GIT_USER_NAME=""
if command -v git >/dev/null 2>&1; then
  GIT_USER_NAME="$(git config --get user.name 2>/dev/null || true)"
fi
if [ -z "$GIT_USER_NAME" ]; then
  GIT_USER_NAME="$DEFAULT_NAME"
fi

CURRENT_DIR="$(json_get '.current_dir')"
if [ -z "$CURRENT_DIR" ]; then
  CURRENT_DIR="$(json_get '.workspace.current_dir')"
fi
if [ -z "$CURRENT_DIR" ]; then
  CURRENT_DIR="$(json_get '.cwd')"
fi
if [ -z "$CURRENT_DIR" ]; then
  CURRENT_DIR="$PWD"
fi

DIR_NAME="$(basename "$CURRENT_DIR" 2>/dev/null || printf '%s' "$CURRENT_DIR")"

MODEL_RAW="$(json_get '.model.model')"
if [ -z "$MODEL_RAW" ]; then
  MODEL_RAW="$(json_get '.model.id')"
fi
if [ -z "$MODEL_RAW" ]; then
  MODEL_RAW="$(json_get '.model')"
fi

MODEL_NAME="$(json_get '.model.display_name')"
if [ -z "$MODEL_NAME" ] && [ -n "$MODEL_RAW" ]; then
  MODEL_NAME="$(detect_model_display_name "$MODEL_RAW")"
fi

OUTPUT_STYLE="$(json_get '.output_style.name')"
if [ -z "$OUTPUT_STYLE" ]; then
  OUTPUT_STYLE="$(json_get '.output_style')"
fi

GIT_SEGMENT=""
if command -v git >/dev/null 2>&1; then
  GIT_BRANCH="$(git -C "$CURRENT_DIR" symbolic-ref --quiet --short HEAD 2>/dev/null || git -C "$CURRENT_DIR" rev-parse --short HEAD 2>/dev/null || true)"
  if [ -n "$GIT_BRANCH" ]; then
    GIT_STATUS="$(git -C "$CURRENT_DIR" status --porcelain --branch 2>/dev/null || true)"
    DIRTY_COUNT="$(printf '%s\n' "$GIT_STATUS" | tail -n +2 | sed '/^$/d' | wc -l | tr -d ' ')"
    AHEAD="$(printf '%s\n' "$GIT_STATUS" | sed -nE 's/^## .*ahead ([0-9]+).*/\1/p' | head -n1)"
    BEHIND="$(printf '%s\n' "$GIT_STATUS" | sed -nE 's/^## .*behind ([0-9]+).*/\1/p' | head -n1)"

    GIT_SEGMENT="$GIT_BRANCH"
    if [ -n "$AHEAD" ]; then
      GIT_SEGMENT="${GIT_SEGMENT} ↑${AHEAD}"
    fi
    if [ -n "$BEHIND" ]; then
      GIT_SEGMENT="${GIT_SEGMENT} ↓${BEHIND}"
    fi
    if [ "${DIRTY_COUNT:-0}" -gt 0 ] 2>/dev/null; then
      GIT_SEGMENT="${GIT_SEGMENT} *${DIRTY_COUNT}"
    fi
  fi
fi

CTX_USED_PCT="$(json_get '.context_window.used_percentage')"
CTX_USED_TOTAL="$(
  json_get '(
    (.context_window.current_usage.input_tokens // 0) +
    (.context_window.current_usage.output_tokens // 0) +
    (.context_window.current_usage.cache_creation_input_tokens // 0) +
    (.context_window.current_usage.cache_read_input_tokens // 0)
  )'
)"
CTX_LIMIT="$(json_get '.context_window.context_window_size')"
CONTEXT_SEGMENT=""
if [ -n "$CTX_USED_TOTAL" ] && [ -n "$CTX_LIMIT" ]; then
  CONTEXT_SEGMENT="$(format_k "$CTX_USED_TOTAL")/$(format_k "$CTX_LIMIT")"
  if [ -n "$CTX_USED_PCT" ]; then
    CONTEXT_SEGMENT="${CONTEXT_SEGMENT} ${CTX_USED_PCT}%"
  fi
fi

SESSION_TOKENS="$(
  json_get '(
    (.context_window.total_input_tokens // 0) +
    (.context_window.total_output_tokens // 0)
  )'
)"
SESSION_SEGMENT=""
if [ -n "$SESSION_TOKENS" ] && [ "${SESSION_TOKENS:-0}" -gt 0 ] 2>/dev/null; then
  SESSION_SEGMENT="$(format_k "$SESSION_TOKENS")"
fi

RATE_5H="$(json_get '.rate_limits.five_hour.used_percentage')"
RATE_7D="$(json_get '.rate_limits.seven_day.used_percentage')"
RATE_SEGMENT=""
if [ -n "$RATE_5H" ] || [ -n "$RATE_7D" ]; then
  RATE_SEGMENT="5h:${RATE_5H:-?}% 7d:${RATE_7D:-?}%"
fi

VIM_MODE="$(json_get '.vim.mode')"

INPUT_COST="$(json_get '.cost.total_cost_usd')"
COST_SEGMENT=""
if [ -n "$INPUT_COST" ]; then
  COST_SEGMENT="\$$(awk -v n="$INPUT_COST" 'BEGIN { printf "%.2f", n }')"
fi

line2=()
[ -n "$MODEL_NAME" ] && line2+=("${C_MODEL}${MODEL_NAME}${C_RESET}")
[ -n "$CONTEXT_SEGMENT" ] && line2+=("${C_CTX}${CONTEXT_SEGMENT}${C_RESET}")
[ -n "$SESSION_SEGMENT" ] && line2+=("${C_SESSION}${SESSION_SEGMENT}${C_RESET}")
[ -n "$VIM_MODE" ] && line2+=("${C_STYLE}${VIM_MODE}${C_RESET}")
[ -n "$OUTPUT_STYLE" ] && line2+=("${C_STYLE}${OUTPUT_STYLE}${C_RESET}")
[ -n "$COST_SEGMENT" ] && line2+=("${C_COST}${COST_SEGMENT}${C_RESET}")

TITLE_LINE="${C_TITLE}${TITLE_PREFIX} ${GIT_USER_NAME}${C_RESET}"
[ -n "$DIR_NAME" ] && TITLE_LINE="${TITLE_LINE}${C_SEP} 😎 ${C_RESET}${C_DIR}${DIR_NAME}${C_RESET}"
[ -n "$GIT_SEGMENT" ] && TITLE_LINE="${TITLE_LINE}${C_SEP} 🌿 ${C_RESET}${C_GIT}${GIT_SEGMENT}${C_RESET}"
[ -n "$RATE_SEGMENT" ] && TITLE_LINE="${TITLE_LINE}${C_SEP} ⏳ ${C_RESET}${C_STYLE}${RATE_SEGMENT}${C_RESET}"

printf '%s\n' "$TITLE_LINE"

if [ "${#line2[@]}" -eq 0 ]; then
  exit 0
fi

printf '%s' "${line2[0]}"
for ((i = 1; i < ${#line2[@]}; i++)); do
  printf '%s%s' "${C_SEP} · ${C_RESET}" "${line2[i]}"
done
printf '\n'


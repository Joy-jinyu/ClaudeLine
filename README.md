# ClaudeLine

Colorful, personality-driven `statusLine` for Claude Code with a one-command install.

## What It Shows

- Your Claude model
- Current workspace directory
- Git branch and dirty state
- Context window usage
- Session token totals
- Rate limit usage
- Vim mode
- Output style
- Session cost

## Install

From this repo:

```bash
./install.sh
```

Install debug mode:

```bash
./install.sh --debug
```

The installer:

- makes `statusline.sh` executable
- backs up `~/.claude/settings.json`
- writes `statusLine.command` for you

## Uninstall

```bash
./uninstall.sh
```

## Customization

Set environment variables in your Claude Code config if you want a different title:

```bash
CLAUDELINE_TITLE_PREFIX="卓尔不凡的"
CLAUDELINE_DEFAULT_NAME="Joy"
```

## Debugging

Debug mode writes raw `statusLine` payloads to:

```text
~/.claude/logs/claudeline-statusline-input.log
```

## Notes

- Multi-line rendering and ANSI effects depend on Claude Code's renderer.
- Colors can be disabled with `NO_COLOR=1`.
- `jq` is required for safe install and uninstall.


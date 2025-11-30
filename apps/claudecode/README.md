# Claude Code Configuration

> ⚠️ Installed via Homebrew

Configuration files for Claude Code

## Structure

`./CLAUDE.global.md` - Global configuration for Claude Code.

## Setup

```bash
./scripts/bash/claudecode.sh
```

Creates symlinks:

- `hooks/*` → `~/.claude/hooks/*`
- `commands/**/*` → `~/.claude/commands/**/*`
- `AGENTS.md` → `~/.claude/CLAUDE.md`

Existing `~/.claude/CLAUDE.md` files are backed up to `CLAUDE.local.md`.

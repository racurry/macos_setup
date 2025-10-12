# Claude Code Configuration

Configuration files for Claude Code, symlinked via `scripts/bash/claudecode.sh`.

## Structure

- `hooks/` - Event hooks (symlinked to `~/.claude/hooks/`)
- `commands/` - Custom slash commands (symlinked to `~/.claude/commands/`, recursive)
- `settings.json` - Claude Code settings (manual install)

## Setup

```bash
./scripts/bash/claudecode.sh
```

Creates symlinks:
- `hooks/*` → `~/.claude/hooks/*`
- `commands/**/*` → `~/.claude/commands/**/*`
- `AGENTS.md` → `~/.claude/CLAUDE.md`

Existing `~/.claude/CLAUDE.md` files are backed up to `CLAUDE.local.md`.

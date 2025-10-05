# Claude Code Setup Guide

## Overview

Claude Code is an AI-powered automation tool that integrates with GitHub to assist with code reviews, issue triage, and automated development tasks. This repository uses Claude Code through both GitHub Actions workflows and the local CLI/VSCode extension.

## Components

### 1. GitHub Actions Integration

The repository includes several automated workflows:

- **claude.yml** - Main workflow triggered by @claude mentions in issues, PRs, and comments
- **claude-code-review.yml** - Automatic code review on pull requests
- **claude-scheduled-review.yml** - Periodic repository health checks
- **claude-triage.yml** - Automated issue triage and labeling

### 2. Local Tools

- **CLI**: Installed via npm (`.default-npm-packages`)
- **VSCode Extension**: Installed via Homebrew (`anthropic.claude-code` in Brewfile)

### 3. Configuration

- **CLAUDE.md**: Repository-level instructions for Claude (symlinked to `~/.claude/CLAUDE.md`)
- **Setup Script**: `scripts/bash/claude_code.sh` - Creates the symlink

## OAuth Token Setup

To enable Claude Code GitHub Actions workflows, you need to create and configure an OAuth token:

### Step 1: Generate OAuth Token

1. Visit [Claude Code OAuth](https://claude.ai/settings/oauth)
2. Sign in with your Anthropic account
3. Click "Generate New Token" or "Create OAuth Token"
4. Copy the generated token immediately (it won't be shown again)

### Step 2: Add Token to GitHub Repository

1. Navigate to your repository settings: `https://github.com/racurry/macos_setup/settings/secrets/actions`
2. Click "New repository secret"
3. Name: `CLAUDE_CODE_OAUTH_TOKEN`
4. Value: Paste the OAuth token from Step 1
5. Click "Add secret"

### Step 3: Verify Configuration

Once the token is added, the workflows will automatically run when triggered. Test by:

1. Creating a test issue with `@claude` in the title or body
2. Or commenting `@claude help` on an existing issue
3. Check the Actions tab to see the workflow run

## Using Claude Code

### Via GitHub Actions

Trigger Claude by mentioning `@claude` in:

- **Issue titles or bodies**: `@claude implement feature X`
- **Issue comments**: `@claude can you review this approach?`
- **PR titles or bodies**: `@claude please review`
- **PR comments**: `@claude explain this change`
- **Adding the `claude` label**: to any issue or PR

Claude will:
- Read repository guidelines from `@AGENTS.md` and `@CLAUDE.md`
- Create branches with `claude/` prefix
- Run tests before submitting changes
- Create PRs with descriptive titles and bodies
- Link PRs to issues automatically
- Follow coding standards and conventions

### Via Local CLI

The Claude Code CLI is installed globally via npm:

```bash
# Start interactive session
claude-code

# Run specific command
claude-code "explain this code"
```

### Via VSCode Extension

The VSCode extension provides:
- Inline code suggestions
- Chat interface for code questions
- Integration with repository context

Access it from the VSCode sidebar after installation.

## Configuration Details

### Workflow Triggers

The main workflow (`claude.yml`) triggers on:
- Issue comment created (containing `@claude`)
- PR review comment created (containing `@claude`)
- PR review submitted (containing `@claude`)
- Issue opened/assigned/labeled (containing `@claude` or label `claude`)
- PR opened/synchronized (containing `@claude`)

### Permissions

Claude Code runs with these GitHub permissions:
- `contents: write` - Create branches and commits
- `pull-requests: write` - Create and update PRs
- `issues: write` - Comment on issues
- `id-token: write` - Authentication
- `actions: read` - Read CI results

### Allowed Commands

For security, Claude can only run pre-approved commands:
- Git operations (checkout, add, commit, push, branch)
- GitHub CLI (pr create/view, issue comment/view)
- Local scripts (via `./` prefix)

### Tools Available to Claude

- File operations: Read, Edit, Write, Glob, Grep
- Shell commands: Bash (restricted to allowed commands)
- Task management: TodoWrite
- External: WebFetch, WebSearch

## Troubleshooting

### Workflow Not Running

1. Check that `CLAUDE_CODE_OAUTH_TOKEN` is set in repository secrets
2. Verify `@claude` is included in the triggering content
3. Check Actions tab for error messages

### OAuth Token Expired

Tokens may expire. If workflows fail with authentication errors:
1. Generate a new token at [Claude Code OAuth](https://claude.ai/settings/oauth)
2. Update the `CLAUDE_CODE_OAUTH_TOKEN` secret in GitHub

### Claude Not Following Guidelines

Ensure:
- `AGENTS.md` contains clear, specific instructions
- `apps/claude_code/CLAUDE.md` is symlinked correctly (run `./scripts/bash/claude_code.sh`)
- Guidelines are referenced in workflow prompt (they are in `claude.yml`)

## Best Practices

1. **Be Specific**: Provide clear, detailed instructions when invoking Claude
2. **Use Context**: Reference files, functions, or issues Claude should review
3. **Review Output**: Always review Claude's PRs before merging
4. **Iterate**: If Claude's first attempt isn't perfect, provide feedback in comments
5. **Security**: Never commit secrets or credentials (Claude is configured to warn about this)

## Resources

- [Claude Code Documentation](https://docs.anthropic.com/claude/docs/claude-code)
- [GitHub Actions Marketplace](https://github.com/marketplace/actions/claude-code)
- [Repository Workflows](.github/workflows/)

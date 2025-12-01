# Zsh

Zsh shell configuration.

## Installation

```bash
brew install zsh
```

## Setup

```bash
./apps/zsh/zsh.sh setup
```

This symlinks `.zshrc` to `~/`.

## Contents

- `.zshrc` - Main Zsh configuration file
- `.galileorc` - Work-specific shell configuration (sourced if present)

## Local Configuration

The `.zshrc` sources `~/.local.zshrc` if it exists. Use this file for:

- API tokens and secrets
- Machine-specific paths
- Personal aliases not suitable for git
- Anything sensitive that shouldn't be committed

Create it manually:

```bash
touch ~/.local.zshrc
```

Example contents:

```bash
export AIRTABLE_API_TOKEN="pat..."
export OPENAI_API_KEY="sk-..."
export MY_CUSTOM_PATH="/some/local/path"
```

This file is **not tracked in git** and should never be committed.

## Syncing Preferences

Repo sync. `.zshrc` symlinked to `~/`.

## References

- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)

# shellcheck

> ⚠️ Installed via Homebrew

Shell script static analysis configuration for consistent bash scripting.

## Contents

- `shellcheckrc` - ShellCheck configuration file
- `shellcheck.sh` - Setup script

## Setup

```bash
./apps/shellcheck/shellcheck.sh setup
```

This symlinks `shellcheckrc` to `~/.config/shellcheckrc` for global usage.

## Configuration

Current settings:

- `external-sources=true` - Follow `source` statements to check included files
- `shell=bash` - Default to bash dialect when not specified by shebang

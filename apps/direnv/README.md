# direnv

Environment switcher for the shell. Automatically loads/unloads environment variables based on current directory.

## Installation

```bash
brew install direnv
```

## Setup

```bash
./apps/direnv/direnv.sh setup
```

This symlinks `use_asdf.sh` to `~/.config/direnv/lib/` for asdf integration.

## Manual Setup

1. **Allow .envrc files** - When entering a directory with `.envrc` for the first time:

   ```bash
   direnv allow
   ```

   This is a security feature - you must explicitly trust each `.envrc`.

## Using with asdf

Add to your project's `.envrc`:

```bash
use asdf
```

This loads tool versions from `.tool-versions` and auto-installs missing runtimes.

## Syncing Preferences

Repo sync. Custom library extensions tracked in this repo, symlinked to `~/.config/direnv/lib/`.

Shell hook is configured in this repo's zsh setup (`.zshrc`).

## References

- [Official Documentation](https://direnv.net/)
- [Configuration Options (direnv.toml)](https://direnv.net/man/direnv.toml.1.html)

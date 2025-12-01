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

1. **Shell hook** - Add to your shell config (already done if using this repo's zsh setup):

   ```bash
   eval "$(direnv hook zsh)"  # or bash
   ```

2. **Allow .envrc files** - When entering a directory with `.envrc`, run:

   ```bash
   direnv allow
   ```

## Using with asdf

Add to your project's `.envrc`:

```bash
use asdf
```

This loads tool versions from `.tool-versions` and auto-installs missing runtimes.

## Syncing Preferences

Repo sync. The custom `use_asdf.sh` library is tracked in this repo and symlinked to `~/.config/direnv/lib/`.

## References

- [Official Documentation](https://direnv.net/)
- [Shell Hook Setup](https://direnv.net/docs/hook.html)

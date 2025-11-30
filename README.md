# Mother Box

This is my "all-in-one" project for managing multiple macOS environments (personal and work) consistently. It houses setup scripts for a new Mac setup, development environment setup, overall app & tool settings, dotfiles, and a handful of convenience scripts that help with various workflows.

## Set up a new mac

1. [Download 1Password](https://1password.com/downloads/mac), install, and sign in
2. Enable SSH agent: Settings → Developer → SSH Agent
3. Clone: `git clone git@github.com:racurry/osx_setup.git ~/workspace/infra/osx_setup`
4. Run: `cd ~/workspace/infra/osx_setup && ./setup.sh`

## Structure

- [apps](./apps) - Application-specific configs and setup scripts, organized by app (each app has its own directory with config files, setup script, and tests)
- [bin](./bin) - Standalone binaries that can be run manually.  Automatically added to PATH
- [lib](./lib) - Shared library functions and helpers
- [scripts](./scripts) - App-agnostic utility scripts
- [docs](./docs) - Todos, manual steps, notes, etc.

## Testing

Tests are distributed throughout the repository, co-located with the code they test.

```bash
./test.sh           # Run all tests (lint + unit)
./test.sh lint      # ShellCheck on all bash sources
./test.sh unit      # BATS unit tests
./test.sh --app brew  # Run tests for specific app only
```

## More to do

[We're never really done](./docs/TODO.md)

## Resources

Things that can help manage or tweak macOS settings

- <http://www.bresink.com/osx/TinkerTool.html>
- <https://formulae.brew.sh/>

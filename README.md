# Motherbox

This is my "all-in-one" project for managing multiple macOS environments (personal and work) consistently. It houses setup scripts for a new Mac setup, development environment setup, overall app & tool settings, dotfiles, and a handful of convenience scripts that help with various workflows.

## Set up a new mac

1. [Download 1Password](https://1password.com/downloads/mac), install, and sign in
2. Enable SSH agent: Settings → Developer → SSH Agent
3. Clone: `git clone git@github.com:racurry/osx_setup.git ~/workspace/infra/osx_setup`
4. Run: `cd ~/workspace/infra/osx_setup && ./setup.sh`

## What's in here?

## Stuff that is managed

- App management via [Homebrew](https://brew.sh/) and [mas](https://github.com/mas-cli/mas) using the [Brewfile](./apps/brew/Brewfile)
- Environment management via [asdf](https://asdf-vm.com/) using [.tool-versions](./apps/asdf/.tool-versions), and global packages for [`nodejs`](./apps/asdf/.default-npm-packages), [`ruby`](./apps/asdf/.default-gems), and [`python`](./apps/asdf/.default-python-packages)
- Configuration files organized by application in [apps](./apps), including [zsh config](./apps/zsh/.zshrc), [git config](./apps/git/.gitconfig), and more.

## Resources

Things that can help manage or tweak macOS settings

- <http://www.bresink.com/osx/TinkerTool.html>
- <https://formulae.brew.sh/>

## Structure

- [apps](./apps) - Application-specific configs and setup scripts, organized by app
- [bin](./bin) - Standalone binaries that can be run manually
- [lib](./lib) - Shared library functions
- [scripts](./scripts) - App-agnostic utility scripts
- [docs](./docs) - Todos, manual steps, notes, etc.
- [tests](./tests) - Tests, separated by type

## Testing

Some tests are here.

```bash
./tests/lint.sh     # ShellCheck on all bash sources
./tests/unit.sh     # BATS unit tests (adds more over time)
```

## More to do

[We're never really done](./docs/TODO.md)

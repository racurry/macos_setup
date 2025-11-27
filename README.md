# Motherbox

This is my "all-in-one" project for managing multiple macOS environments (personal and work) consistently. It houses setup scripts for a new Mac setup, development environment setup, overall app & tool settings, dotfiles, and a handful of convenience scripts that help with various workflows.

## Set up a new mac

Pre-requisites:
Step 1 - set up your dirs: `mkdir -p ~/.ssh && chmod 700 ~/.ssh && mkdir -p ~/workspace/infra`
Step 2 - get the ssh key: [Download](<https://1password.com/downloads/mac>), install, and sign in.  Copy the ssh key to your clipboard.
Step 3 - put it in place: `pbpaste > ~/.ssh/id_personal_github && chmod 600 ~/.ssh/id_personal_github && echo -e "Host github.com\n    IdentityFile ~/.ssh/id_personal_github" > ~/.ssh/config && git clone git@github.com:racurry/osx_setup.git ~/workspace/infra/osx_setup`

Run the setup script:

```bash
cd ~/workspace/infra/osx_setup
./setup.sh
```

## What's in here?

## Stuff that is managed

- App management via [Homebrew](https://brew.sh/) and [mas](https://github.com/mas-cli/mas) using the [Brewfile](./dotfiles/Brewfile)
- Environment management via [asdf](https://asdf-vm.com/) using [.tool-versions](./dotfiles/.tool-versions), and global packages for [`nodejs`](./dotfiles/.default-npm-packages), [`ruby`](./dotfiles/.default-gems), and [`python`](./dotfiles/.default-python-packages)
- Dotfiles in [dotfiles](./dotfiles) symlinked to `~/.dotfiles`, including [zsh config](./dotfiles/.zshrc), [git config](./dotfiles/.gitconfig), and more.

## Resources

Things that can help manage or tweak macOS settings

- <http://www.bresink.com/osx/TinkerTool.html>
- <https://formulae.brew.sh/>

## Structure

- [bin](./bin) - Standalone binaries that can be run manually
- [lib](./lib) - Shared library functions
- [scripts/bash](./scripts/bash) - Scripts, separated by language
- [dotfiles](./dotfiles) - Dotfiles to be symlinked to the home directory
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

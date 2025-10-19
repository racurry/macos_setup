# macOS Setup

## Set up a new Mac

**Step 1:**

1. Generate a new ssh key:
`ssh-keygen -t rsa`
2. Copy it to your clipboard:
`pbcopy < ~/.ssh/id_rsa.pub`
3. Add it here: [github settings](https://github.com/settings/keys)

**Step 2:**

```bash
mkdir ~/workspace
cd ~/workspace
git clone git@github.com:racurry/osx_setup.git
```

**Step 3:**

This will run the full setup process.  Sometimes, it might need manual intervention; do what it says and run it again. It is idempotent, run it til its done.

```bash
# Normal setup (requires sudo for some operations)
./setup.sh

# Non-interactive setup (skip sudo operations)
./setup.sh --skip-sudo
```

### Setup Options

- `--skip-sudo` - Skip operations requiring sudo (useful for CI/CD or non-interactive environments)
- `--mode=MODE` - Set mode directly (work or personal)
- `--reset-mode` - Reset saved work/personal mode
- `-h, --help` - Show help message

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

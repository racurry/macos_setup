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
./setup.sh
```

## What's in here?

## AI Automation

This repository uses [Claude Code](https://docs.anthropic.com/claude/docs/claude-code) for automated development assistance:

- **GitHub Actions Integration**: Trigger Claude by mentioning `@claude` in issues, PRs, or comments
- **Automated Code Reviews**: Claude reviews all pull requests automatically
- **Issue Triage**: Automated labeling and categorization of issues
- **Local CLI & VSCode Extension**: Use Claude directly in your development environment

See the [Claude Code setup guide](./apps/claude_code/setup.md) for configuration details and OAuth token setup.

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

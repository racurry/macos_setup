# Visual Studio Code

Code editor with extensive extension ecosystem.

## Installation

```bash
brew install --cask visual-studio-code
```

## Setup

```bash
./apps/vscode/vscode.sh setup
```

This installs all VSCode extensions defined in `apps/vscode/Brewfile`.

To add an extension:

1. Find the extension ID in VSCode (right-click extension > Copy Extension ID)
2. Add `vscode "publisher.extension-id"` to `apps/vscode/Brewfile`
3. Run `./apps/vscode/vscode.sh setup`

## Manual Setup

Complete these steps after installation:

1. **Enable Settings Sync** - Open Command Palette > "Settings Sync: Turn On" > Sign in with GitHub (not MS!)
2. **Wait for sync** - Extensions, settings, keybindings, and snippets will sync automatically

## Syncing Preferences

Native sync via VSCode Settings Sync. Sign in with GitHub or Microsoft account to sync settings, keybindings, extensions, and snippets across machines.

Extensions are also tracked in `apps/vscode/Brewfile` as a backup and for fresh installs before signing in.

## References

- [VSCode Settings Sync](https://code.visualstudio.com/docs/editor/settings-sync)
- [Homebrew VSCode Extension Management](https://docs.brew.sh/Manpage#bundle-subcommand)

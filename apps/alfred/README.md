# Alfred

Application launcher and productivity software for macOS.

## Installation

```bash
brew install --cask alfred
```

## Setup

```bash
./apps/alfred/alfred.sh setup
```

This configures:

- Hotkey: Ctrl+Opt+Space
- Theme: Yosemite

## Manual Setup

Complete these steps after installation:

1. **Grant Accessibility permission** - System Settings > Privacy & Security > Accessibility > enable Alfred
2. **Grant Full Disk Access** (optional) - For searching protected locations
3. **Activate Powerpack** - Alfred Preferences > Powerpack (required for workflows, snippets, clipboard history, and sync)

## Syncing Preferences

Alfred Preferences > Advanced > Set preferences folder. Point to a cloud-synced folder (Dropbox recommended). Avoid iCloud due to sync reliability issues with Optimised Storage.

## References

- [Official Documentation](https://www.alfredapp.com/help/)
- [Granting Permissions](https://www.alfredapp.com/help/getting-started/permissions/)
- [Sync Preferences Guide](https://www.alfredapp.com/help/advanced/sync/)

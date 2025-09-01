# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a sophisticated macOS setup automation system built with Ruby orchestration, secure password handling, and smart execution tracking. The system automates comprehensive macOS configuration including system preferences, application installation, and dotfile management.

## Key Commands

### Main Setup Commands

- `./macos_setup` - Primary entry point for complete macOS setup with secure password collection
- `./macos_setup --force` - Force complete re-run by clearing execution tracking data
- `./macos_setup --update` - Run system hygiene (updates packages, plugins, configurations)
- `macoscfg` - Global command (created after first run) for re-running setup from anywhere
- `machygiene` - Global command (created after first run) for running system hygiene

### Individual Component Scripts

- `bin/full_setup [--verbose] [--force]` - Main orchestrator with smart execution tracking
- `bin/setup_macos` - Configure macOS system preferences and defaults
- `bin/sync_dotfiles` - Sync configuration files with interactive conflict resolution
- `bin/install_apps` - Install shell applications and Brewfile packages
- `bin/manage_packages [--update] [--upgrade] [--verbose]` - Install/update asdf packages and global npm/pip/gem packages
- `bin/manual_todos` - Interactive checklist for manual configuration tasks
- `bin/hygiene` - System hygiene routine (updates packages, plugins, configurations)
- `bin/create_folders` - Create standard folder structure
- `bin/setup_app_configs` - Configure application settings

### Development Commands

- `brew bundle --file=data/Brewfile` - Install/update all packages
- `brew bundle check --file=data/Brewfile` - Verify all packages are installed
- `npm install -g` (in data/) - Install npm global packages from package.json
- `bundle install --system` (in data/) - Install gem packages from Gemfile
- `pip install -r requirements.txt` (in data/) - Install pip packages from requirements.txt
- `git pull --rebase` - Update to latest configuration (run automatically by setup)

## Architecture

### Secure Password Management System

The system implements enterprise-grade password handling:

- **Single Password Prompt**: `macos_setup` collects password once with hidden input (`stty -echo`)
- **Secure Storage**: Password stored in `/tmp/macos_setup_{PID}` with 0600 permissions
- **Sudo Helper**: `bin/sudo_helper` reads from temp file when called by sudo processes
- **Automatic Cleanup**: Password file deleted via `ensure` block even on errors
- **Environment Integration**: Uses `SUDO_ASKPASS` to enable passwordless sudo throughout execution

### Smart Execution Tracking

`bin/full_setup` implements intelligent re-execution logic:

- **Timestamp Tracking**: Stores execution times in `data/.meta/last_run/`
- **File Modification Detection**: Only re-runs when scripts or data files change
- **Idempotent Design**: Safe to run multiple times without side effects
- **State Preservation**: Partial runs can be resumed without starting over

### Package Management

- **Single Brewfile**: `data/Brewfile` contains all packages (brew, cask, mas)
- **Shell Apps**: `data/install_shell_apps.json` defines prerequisite tools (Xcode CLI, Homebrew, Oh My Zsh)
- **Language Packages**: Separate files for npm (`package.json`), pip (`requirements.txt`), and Ruby gems (`Gemfile`)
- **Version Management**: Uses asdf with `.tool-versions` for language runtime versions

### System Configuration

The setup process configures comprehensive macOS settings:

- **Global Preferences**: Dark mode, scroll bars, save/print panel expansion
- **Keyboard**: Fast key repeats, disabled autocorrect/capitalize, full keyboard access
- **Dock**: Autohide, left position, no bouncing, Mission Control hot corners
- **Trackpad**: Tap-to-click, right-click, Force Click enabled
- **Finder**: Show extensions/hidden files, column view, status/path bars
- **Screenshots**: Custom location, PNG format, no thumbnails

### Execution Flow

1. **`macos_setup`**: Password collection → validation → delegation to `bin/full_setup`
2. **`bin/full_setup`**: Git update → sequential module execution with tracking
3. **Modules execute in order**:
   - `create_folders`: Create standard directory structure
   - `setup_macos`: System preferences and defaults
   - `sync_dotfiles`: Configuration file synchronization  
   - `install_apps`: Shell tools + Brewfile installation
   - `manage_packages`: Install/update development packages (asdf, npm, pip, gem)
   - `setup_app_configs`: Configure application settings
   - `manual_todos`: Interactive manual task checklist
4. **Path Integration**: Creates `/usr/local/bin/macoscfg` and `/usr/local/bin/machygiene` symlinks

### Configuration Management

- **Dotfiles**: `data/dotfiles/` → symlinked to home directory with conflict resolution
- **System Settings**: Comprehensive macOS defaults in `bin/setup_macos`
- **Package Lists**: Brewfile for all Homebrew packages, JSON for shell apps
- **Global Packages**: Standard package manager files in `data/` directory
- **Manual Tasks**: Persistent checklist with completion tracking in `data/manual_todos.txt`

## File Structure

```
osx_setup/
├── macos_setup              # Main entry point with Ruby version detection
├── bin/                     # Executable scripts
│   ├── full_setup          # Main orchestrator with smart tracking
│   ├── sudo_helper         # SUDO_ASKPASS helper for password handling
│   ├── setup_macos         # macOS system preferences configuration
│   ├── sync_dotfiles       # Dotfile synchronization with conflict resolution
│   ├── install_apps        # Shell apps and Brewfile package installation
│   ├── manage_packages     # asdf/npm/pip/gem package management
│   ├── hygiene             # System maintenance and updates
│   └── manual_todos        # Interactive manual task checklist
├── data/                   # Configuration files and package lists
│   ├── Brewfile           # All Homebrew packages (brew/cask/mas)
│   ├── install_shell_apps.json  # Shell prerequisites (Xcode, Homebrew, Oh My Zsh)
│   ├── package.json       # Global npm packages
│   ├── Gemfile           # Ruby gems
│   ├── requirements.txt  # Python pip packages
│   ├── manual_todos.txt  # Manual configuration checklist
│   ├── dotfiles/         # Configuration files to symlink
│   └── .meta/            # Execution tracking and backups (git-ignored)
└── lib/                  # Ruby helper modules
    ├── terminal_helpers.rb  # Colored output and formatting
    ├── sudo_manager.rb     # Secure password handling
    └── brew_apps_installer.rb  # Brewfile installation logic
```

## Development Guidelines

### Password Security
- Never store passwords in environment variables or logs
- Use temp files with restrictive permissions (0600)
- Always implement cleanup via `ensure` blocks
- Test password validation before proceeding with operations

### Smart Execution
- Check file modification times before re-running expensive operations
- Store tracking data in `data/.meta/` directory structure
- Implement idempotent operations that can run repeatedly safely
- Provide both verbose and quiet execution modes

### Package Management
- Keep Brewfile packages alphabetically sorted within categories
- Test installations on clean systems before committing changes
- Handle Rosetta/ARM compatibility issues gracefully
- Separate sudo-requiring apps only when necessary for UX

### Error Handling
- Use exit codes and colored output for clear status reporting
- Implement graceful degradation when optional components fail
- Provide helpful error messages with actionable next steps
- Maintain system state consistency even on partial failures

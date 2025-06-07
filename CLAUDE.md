# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a sophisticated macOS setup automation system built with Ruby orchestration, secure password handling, and smart execution tracking. The system automates comprehensive macOS configuration including system preferences, application installation, and dotfile management.

## Key Commands

### Main Setup
- `./macos_setup` - Primary entry point for complete macOS setup with secure password collection
- `./macos_setup --force` - Force complete re-run by clearing execution tracking data
- `macoscfg` - Global command (created after first run) for re-running setup from anywhere

### Individual Components (for development/testing)
- `bin/full_setup [--verbose] [--force]` - Main orchestrator with smart execution tracking
- `bin/setup_macos` - Configure macOS system preferences and defaults
- `bin/sync_dotfiles` - Sync configuration files with interactive conflict resolution
- `bin/install_apps` - Install shell applications and Brewfile packages
- `bin/manual_todos` - Interactive checklist for manual configuration tasks

### Development Commands
- `brew bundle --file=data/Brewfile` - Install/update all packages
- `brew bundle check --file=data/Brewfile` - Verify all packages are installed
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

### Unified Package Management
- **Single Brewfile**: `data/Brewfile` contains all packages (brew, cask, mas)
- **Transparent Sudo**: Sudo-requiring apps install without additional prompts
- **Error Resilience**: Checks actual installation status even when bundle reports errors
- **Application Categories**:
  - Homebrew packages: CLI tools (git, gh, asdf, imagemagick)
  - Homebrew casks: GUI apps (Alfred, Arc, Cursor, VS Code, Stream Deck)
  - Mac App Store apps: Native apps (Things, CARROT Weather, Meeter)

### Execution Flow
1. **`macos_setup`**: Password collection → validation → delegation to `bin/full_setup`
2. **`bin/full_setup`**: Git update → sequential module execution with tracking
3. **Modules execute in order**:
   - `setup_macos`: System preferences and defaults
   - `sync_dotfiles`: Configuration file synchronization  
   - `install_apps`: Shell tools + Brewfile installation
   - `manual_todos`: Interactive manual task checklist
4. **Path Integration**: Creates `/usr/local/bin/macoscfg` symlink

### Configuration Management
- **Dotfiles**: `data/dotfiles/` → symlinked to home directory
- **System Settings**: Comprehensive macOS defaults in `setup_macos`
- **Application Lists**: JSON-driven shell app installation
- **Manual Tasks**: Persistent checklist with completion tracking

### Terminal Interface
Uses `lib/terminal_helpers.rb` for consistent UX:
- Colored output with semantic styling (green=success, yellow=warning, red=error)
- Section headers/footers with visual separation
- Progress indicators and status reporting
- 80-character column formatting standards

## Development Notes

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

### Brewfile Management
- Keep packages alphabetically sorted within categories
- Test installations on clean systems before committing changes
- Handle Rosetta/ARM compatibility issues gracefully
- Separate sudo-requiring apps only when necessary for UX

### Error Handling
- Use exit codes and colored output for clear status reporting
- Implement graceful degradation when optional components fail
- Provide helpful error messages with actionable next steps
- Maintain system state consistency even on partial failures

### File Structure
- `macos_setup` - Main entry point with password handling
- `bin/` - Executable scripts and helpers
- `data/` - Configuration files, package lists, and state tracking
- `lib/` - Ruby helper modules for terminal formatting
- Tracking state stored in `data/.meta/` (git-ignored)
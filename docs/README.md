# macOS Setup Documentation

This repository automates macOS system setup and configuration management. It manages applications, dotfiles, runtime environments, and system settings through a collection of scripts and configuration files.

**For software development tools, see [dev_tools.md](dev_tools.md).**

## Table of Contents

- [Applications](#applications)
- [Scripts](#scripts)
- [Utilities](#utilities)
- [Related Documentation](#related-documentation)

---

## Applications

All applications are managed via [Homebrew](https://brew.sh/) and defined in [`dotfiles/Brewfile`](../dotfiles/Brewfile), with additional mode-specific apps in [`dotfiles/Brewfile.personal`](../dotfiles/Brewfile.personal) and [`dotfiles/Brewfile.work`](../dotfiles/Brewfile.work).

### Productivity & Automation

- **raycast** - Powerful macOS launcher and productivity tool
- **keyboard-maestro** - Advanced macOS automation and macro tool
- **hazel** - Automated file organization and management
- **obsidian** - Knowledge base and note-taking with markdown
- **Things** - Task management and GTD application (Mac App Store)
- **Actions For Obsidian** - iOS shortcuts integration for Obsidian (Mac App Store)

### Communication & Collaboration

- **mailmate** - Advanced IMAP email client for macOS
  - Setup: [`scripts/bash/mailmate.sh`](../scripts/bash/mailmate.sh)
- **spotify** - Music streaming service

### File Management & Storage

- **renamer** - Batch file renaming tool
- **google-drive** - Cloud storage and file synchronization
- **The Unarchiver** - Archive extraction utility (Mac App Store)
- **Rapidmg** - DMG file creation utility (Mac App Store)

### Media & Graphics

- **shottr** - Feature-rich screenshot and annotation tool
  - Config: [`apps/shottr.md`](../apps/shottr.md)
- **ffmpeg** - Complete multimedia processing toolkit
- **imagemagick** - Image manipulation and conversion library
- **gifsicle** - GIF creation and optimization tool

### System Utilities

- **caffeine** - Prevents Mac from sleeping
- **Amphetamine** - Advanced keep-awake utility (Mac App Store)
- **flux-app** - Screen color temperature adjustment
- **mos** - Mouse and trackpad configuration tool
- **jordanbaird-ice** - Menu bar management tool

### Browsers

- **arc** - Modern browser with built-in productivity features

### Hardware Integration

- **elgato-stream-deck** - Stream Deck hardware control software
  - Config: [`apps/stream_deck.md`](../apps/stream_deck.md)
- **mutedeck** - Audio mute control via Stream Deck
  - Config: [`apps/mute_deck.md`](../apps/mute_deck.md)

### Document Processing

- **qpdf** - PDF transformation and manipulation tool
- **textbuddy** - Text file analysis and cleaning
- **libreoffice** - Open-source office suite
- **codex** - Document and file organizer

### Calendar & Scheduling

- **Meeter** - Menu bar calendar and meeting tool (Mac App Store)

### Weather

- **CARROTweather** - Snarky weather application (Mac App Store)

### Personal Applications

Installed via [`dotfiles/Brewfile.personal`](../dotfiles/Brewfile.personal):

- **daisydisk** - Visual disk space analyzer
- **macwhisper** - Local speech-to-text transcription
- **Duplicate Photos Finder** - Photo duplicate detection (Mac App Store)
- **Goodnotes** - Note-taking and PDF annotation (Mac App Store)
- **Home Inventory** - Personal inventory management (Mac App Store)
- **Paprika Recipe Manager 3** - Recipe organization and meal planning (Mac App Store)
- **Parachute** - Window management utility (Mac App Store)
- **PhotoSweeper** - Advanced duplicate photo finder (Mac App Store)
- **PocketTube** - YouTube subscription organizer (Mac App Store)
- **Pixelmator Pro** - Professional image editing (Mac App Store)
- **Signals** - Stock market tracker (Mac App Store)
- **Shortery** - Keyboard shortcut manager (Mac App Store)
- **Soulver 3** - Notepad calculator (Mac App Store)
- **Toolkit for YNAB** - You Need A Budget browser extension (Mac App Store)
- **Yomu** - Manga and comic reader (Mac App Store)

---

## Scripts

All scripts are located in [`scripts/`](../scripts/) and organized by language.

### Bash Scripts

Located in [`scripts/bash/`](../scripts/bash/):

- **brew.sh** - Installs Homebrew and manages Brewfile packages
  - Commands: `install`, `bundle`
  - Supports `SETUP_MODE` environment variable for work/personal Brewfiles
- **devonthink.sh** - DEVONthink configuration and setup
- **dotfiles.sh** - Symlinks dotfiles from `dotfiles/` to home directory
- **folders.sh** - Creates standard workspace directory structure
- **icloud.sh** - iCloud Drive configuration
- **icloud_sync_fix.sh** - Repairs iCloud sync issues
- **macos_settings.sh** - Applies macOS system preferences
  - Commands: `global`, `input`, `dock`, `finder`, `misc`, `all`
  - See: [`scripts/bash/macos_settings.sh`](../scripts/bash/macos_settings.sh)
- **mailmate.sh** - MailMate email client configuration

### Python Scripts

Located in [`scripts/python/`](../scripts/python/):

- **split_pdf.py** - Splits PDF files into individual pages

### JavaScript Scripts

Located in [`scripts/js/`](../scripts/js/) - currently no scripts defined.

---

## Utilities

Command-line utilities in [`bin/`](../bin/). Full documentation: [`docs/SCRIPTS.md`](SCRIPTS.md)

### Video Conversion

- **avitomp4** - Converts AVI files to MP4 using ffmpeg
- **mkvtomp4** - Converts MKV files to MP4 using ffmpeg
- **vidmerge** - Merges multiple videos into single MP4

### Image Processing

- **backgroundify** - Adds solid color backgrounds to transparent images
- **iconify** - Creates macOS .icns icon files from images
- **ocrify** - Performs OCR on images/PDFs using Tesseract

### File Organization

- **folderify** - Moves each file into its own subdirectory
- **unfolderify** - Flattens directory structure

### File Naming

- **batch_rename** - Renames files with sequential numbering
- **filename_fixer** - Cleans and standardizes filenames
- **swap_extension** - Bulk file extension changes

### General Utilities

- **folderpaint** - Folder icon customization utility

---

## Related Documentation

- **[dev_tools.md](dev_tools.md)** - Software development tools and configurations
- **[TESTING_PLAN.md](TESTING_PLAN.md)** - Test strategy and coverage
- **[SCRIPTS.md](SCRIPTS.md)** - Detailed utility script documentation
- **[TODO.md](TODO.md)** - Ongoing tasks and improvements
- **[APP_AUDIT.md](APP_AUDIT.md)** - Application installation audit report
- **[manual_todos.md](manual_todos.md)** - Manual configuration steps

---

## Quick Links

- Main Brewfile: [`dotfiles/Brewfile`](../dotfiles/Brewfile)
- Personal Apps: [`dotfiles/Brewfile.personal`](../dotfiles/Brewfile.personal)
- Work Apps: [`dotfiles/Brewfile.work`](../dotfiles/Brewfile.work)
- Setup Script: [`setup.sh`](../setup.sh)
- Main README: [`README.md`](../README.md)
- Development Tools: [dev_tools.md](dev_tools.md)

#!/usr/bin/env bash

# ===============================================================================
# Centralized Path Definitions
# ===============================================================================
#
# This file defines all common paths used throughout the repository.
# Source this file to access path constants without hardcoding paths everywhere.
#
# Usage:
#   source "${SCRIPT_DIR}/../../lib/bash/paths.sh"
#
# All exported variables use the PATH_* or FOLDER_* prefix.
#
# ===============================================================================

# User directory paths
export PATH_DOCUMENTS="${HOME}/Documents"
export PATH_SCREENSHOTS="${HOME}/Screenshots"
export PATH_DESKTOP="${HOME}/Desktop"

# Application data paths
export PATH_SSH_DIR="${HOME}/.ssh"
export PATH_SSH_BACKUPS="${HOME}/.ssh/backups"
export PATH_DOTFILES_BACKUP="${HOME}/.dotfiles_backup"
export PATH_CLAUDE="${HOME}/.claude"

# Document organization folder names (used by folders.sh)
export FOLDER_AUTO="@auto"
export FOLDER_INBOX="000_Inbox"
export FOLDER_LIFE="100_Life"
export FOLDER_PROJECTS="150_Projects"
export FOLDER_PEOPLE="200_People"
export FOLDER_TOPICS="400_Topics"
export FOLDER_LIBRARIES="700_Libraries"
export FOLDER_POSTERITY="800_Posterity"
export FOLDER_META="999_Meta"

# iCloud paths
export PATH_ICLOUD_MOBILE_DOCUMENTS="${HOME}/Library/Mobile Documents/com~apple~CloudDocs"

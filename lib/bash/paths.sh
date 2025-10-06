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
# All exported variables use the SETUP_PATH_* or SETUP_FOLDER_* prefix.
#
# ===============================================================================

# User directory paths
export SETUP_PATH_DOCUMENTS="${HOME}/Documents"
export SETUP_PATH_SCREENSHOTS="${HOME}/Screenshots"
export SETUP_PATH_DESKTOP="${HOME}/Desktop"

# Application data paths
export SETUP_PATH_SSH_DIR="${HOME}/.ssh"
export SETUP_PATH_SSH_BACKUPS="${HOME}/.ssh/backups"
export SETUP_PATH_DOTFILES_BACKUP="${HOME}/.dotfiles_backup"
export SETUP_PATH_CLAUDE="${HOME}/.claude"

# Document organization folder names (used by folders.sh)
export SETUP_FOLDER_AUTO="@auto"
export SETUP_FOLDER_INBOX="000_Inbox"
export SETUP_FOLDER_LIFE="100_Life"
export SETUP_FOLDER_PROJECTS="150_Projects"
export SETUP_FOLDER_PEOPLE="200_People"
export SETUP_FOLDER_TOPICS="400_Topics"
export SETUP_FOLDER_LIBRARIES="700_Libraries"
export SETUP_FOLDER_POSTERITY="800_Posterity"
export SETUP_FOLDER_META="999_Meta"

# iCloud paths
export SETUP_PATH_ICLOUD_MOBILE_DOCUMENTS="${HOME}/Library/Mobile Documents/com~apple~CloudDocs"

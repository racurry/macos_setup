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
# All exported variables use the PATH_* prefix.
#
# ===============================================================================

# Mother Box paths (this project's config and data)
export PATH_MOTHERBOX_CONFIG="${HOME}/.config/motherbox"
export PATH_MOTHERBOX_BACKUPS="${PATH_MOTHERBOX_CONFIG}/backups"

# User directory paths
export PATH_DOCUMENTS="${HOME}/Documents"
export PATH_SCREENSHOTS="${HOME}/Screenshots"
export PATH_DESKTOP="${HOME}/Desktop"
export PATH_DOWNLOADS="${HOME}/Downloads"

# iCloud paths
export PATH_ICLOUD="${HOME}/iCloud"
export PATH_ICLOUD_MOBILE_DOCUMENTS="${HOME}/Library/Mobile Documents/com~apple~CloudDocs"

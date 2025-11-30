#!/bin/bash
# Common helper functions for setup scripts.

# Determine repo root relative to this file.
COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# COMMON_DIR is lib/bash, so bubble up two levels to reach the repo root.
REPO_ROOT="$(cd "${COMMON_DIR}/../.." && pwd)"

# Source paths for centralized path definitions
# shellcheck source=lib/bash/paths.sh
source "${COMMON_DIR}/paths.sh"
LOG_TAG="setup"

# Color codes for readability.
CLR_RESET=$'\033[0m'   # reset / default
CLR_INFO=$'\033[1;34m' # bright blue for informational messages
CLR_WARN=$'\033[1;33m' # bright yellow for warnings
CLR_ERROR=$'\033[1;31m' # bright red for errors
CLR_SUCCESS=$'\033[1;32m' # bright green for success messages
CLR_BOLD=$'\033[1m'    # bold text
CLR_CYAN=$'\033[1;36m' # bright cyan for headings

log_info() {
  printf "%s[%s] %s%s\n" "${CLR_INFO}" "${LOG_TAG}" "$*" "${CLR_RESET}"
}

log_warn() {
  printf "%s[%s] %s%s\n" "${CLR_WARN}" "${LOG_TAG}" "$*" "${CLR_RESET}" >&2
}

log_error() {
  printf "%s[%s] %s%s\n" "${CLR_ERROR}" "${LOG_TAG}" "$*" "${CLR_RESET}" >&2
}

log_success() {
  printf "%s[%s] %s%s\n" "${CLR_SUCCESS}" "${LOG_TAG}" "$*" "${CLR_RESET}"
}

fail() {
  log_error "$*"
  exit 1
}

# =============================================================================
# Configuration Management
# =============================================================================
# Config file: ~/.config/motherbox/config
# Format: Shell variables that can be sourced
#
# Default values:
#   BACKUP_RETENTION_DAYS=60
#   SETUP_MODE=           (empty, set by run/setup.sh)
# =============================================================================

# _config_defaults returns default config values as shell assignments
_config_defaults() {
  cat << 'EOF'
BACKUP_RETENTION_DAYS=60
SETUP_MODE=
EOF
}

# ensure_config creates the config file with defaults if it doesn't exist.
# Called automatically by get_config and set_config.
# Silent by default to avoid disrupting output.
ensure_config() {
  if [[ -f "${PATH_MOTHERBOX_CONFIG_FILE}" ]]; then
    return 0
  fi

  mkdir -p "${PATH_MOTHERBOX_CONFIG}"
  _config_defaults > "${PATH_MOTHERBOX_CONFIG_FILE}"
}

# get_config retrieves a configuration value.
# Usage: get_config <key>
# Returns: The value via stdout, or empty string if not set
get_config() {
  local key="$1"

  ensure_config

  # Source config in subshell and echo the requested variable
  (
    # shellcheck source=/dev/null
    source "${PATH_MOTHERBOX_CONFIG_FILE}"
    eval "echo \"\${${key}:-}\""
  )
}

# set_config sets a configuration value.
# Usage: set_config <key> <value>
# Creates config file with defaults if it doesn't exist.
set_config() {
  local key="$1"
  local value="$2"

  ensure_config

  # Read current config
  local tmp_file
  tmp_file="$(mktemp)"

  # Update or add the key
  if grep -q "^${key}=" "${PATH_MOTHERBOX_CONFIG_FILE}"; then
    # Key exists, update it
    sed "s|^${key}=.*|${key}=${value}|" "${PATH_MOTHERBOX_CONFIG_FILE}" > "${tmp_file}"
  else
    # Key doesn't exist, append it
    cat "${PATH_MOTHERBOX_CONFIG_FILE}" > "${tmp_file}"
    echo "${key}=${value}" >> "${tmp_file}"
  fi

  mv "${tmp_file}" "${PATH_MOTHERBOX_CONFIG_FILE}"
}

# =============================================================================

# require_command ensures a binary is available before we call it.
require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    fail "Required command '$cmd' not found in PATH"
  fi
}

# require_file guards against missing manifest/config files.
require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    fail "Required file '$path' is missing"
  fi
}

# require_directory guards against missing directories.
require_directory() {
  local path="$1"
  if [[ ! -d "$path" ]]; then
    fail "Required directory '$path' is missing"
  fi
}

# prune_backups removes backup files older than BACKUP_RETENTION_DAYS.
# Usage: prune_backups
# Cleans up empty directories after pruning.
# Retention period is read from config (default: 60 days).
prune_backups() {
  if [[ ! -d "${PATH_MOTHERBOX_BACKUPS}" ]]; then
    return 0
  fi

  local retention_days
  retention_days="$(get_config BACKUP_RETENTION_DAYS)"
  retention_days="${retention_days:-60}"  # Fallback if empty

  # Find and delete files older than retention period, logging each deletion
  while IFS= read -r -d '' file; do
    log_warn "Pruning old backup: ${file}"
    rm -f "$file"
  done < <(find "${PATH_MOTHERBOX_BACKUPS}" -type f -mtime "+${retention_days}" -print0 2>/dev/null)

  # Clean up empty directories
  find "${PATH_MOTHERBOX_BACKUPS}" -type d -empty -delete 2>/dev/null || true
}

# backup_file moves a file to the Mother Box backups directory.
# Usage: backup_file <file_path> <app_name>
# Creates: ~/.config/motherbox/backups/<datetime>/<app_name>/<filename>.<timestamp>
# Triggers pruning of backups older than 60 days.
backup_file() {
  local file_path="$1"
  local app_name="$2"

  if [[ -z "$app_name" ]]; then
    fail "backup_file requires app_name argument"
  fi

  if [[ ! -e "$file_path" ]]; then
    return 0
  fi

  local filename datestamp timestamp backup_dir backup_path
  filename="$(basename "$file_path")"
  datestamp="$(date +%Y%m%d)"
  timestamp="$(date +%Y%m%d_%H%M%S)"
  backup_dir="${PATH_MOTHERBOX_BACKUPS}/${datestamp}/${app_name}"
  backup_path="${backup_dir}/${filename}.${timestamp}"

  mkdir -p "$backup_dir"
  mv "$file_path" "$backup_path"
  touch "$backup_path"  # Reset mtime so pruning uses backup time, not original file time
  log_warn "Backed up ${filename} to ${backup_path}"

  # Opportunistic pruning
  prune_backups
}

print_heading() {
  local text="$1"
  printf "\n\033[1;36m==> %s\033[0m\n" "$text"
}

# check_rosetta verifies Rosetta 2 is installed on Apple Silicon.
check_rosetta() {
  if ! pgrep -q oahd; then
    return 1
  fi
  return 0
}

# require_rosetta ensures Rosetta 2 is installed, failing with instructions if not.
require_rosetta() {
  if ! check_rosetta; then
    log_error "Rosetta 2 is not installed but is required"
    log_info "Install with: softwareupdate --install-rosetta --agree-to-license"
    fail "Rosetta 2 installation required"
  fi
}

# link_file creates or updates a symlink, backing up existing files if needed.
# Usage: link_file <source> <destination> <app_name>
# - If destination is already a correct symlink, does nothing
# - If destination is a different symlink, replaces it (no backup needed)
# - If destination is a regular file, backs it up using backup_file
# - app_name is REQUIRED
link_file() {
    local src="$1"
    local dest="$2"
    local app_name="$3"

    if [[ -z "${app_name}" ]]; then
        fail "link_file requires app_name argument"
    fi

    if [[ -L "${dest}" ]]; then
        local current_target
        current_target="$(readlink "${dest}")"
        if [[ "${current_target}" == "${src}" ]]; then
            log_info "Symlink already correct: ${dest}"
            return 0
        fi
        log_info "Replacing existing symlink ${dest}"
        rm "${dest}"
    elif [[ -e "${dest}" ]]; then
        backup_file "${dest}" "${app_name}"
    fi

    ln -s "${src}" "${dest}"
    log_info "Linked ${dest} -> ${src}"
}

# copy_file copies a file to destination, backing up existing files if needed.
# Usage: copy_file <source> <destination> <app_name>
# - If destination is a symlink, removes it and copies
# - If destination is a regular file, backs it up using backup_file
# - app_name is REQUIRED
# Use this for apps that don't follow symlinks.
copy_file() {
    local src="$1"
    local dest="$2"
    local app_name="$3"

    if [[ -z "${app_name}" ]]; then
        fail "copy_file requires app_name argument"
    fi

    if [[ -L "${dest}" ]]; then
        log_info "Removing existing symlink ${dest}"
        rm "${dest}"
    elif [[ -e "${dest}" ]]; then
        backup_file "${dest}" "${app_name}"
    fi

    cp "${src}" "${dest}"
    log_info "Copied ${src} -> ${dest}"
}

# Guard against sourcing multiple times.
export REPO_ROOT

# Export color codes for external use
export CLR_RESET CLR_INFO CLR_WARN CLR_ERROR CLR_SUCCESS CLR_BOLD CLR_CYAN

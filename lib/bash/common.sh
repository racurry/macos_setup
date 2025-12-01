#!/bin/bash
# Common helper functions for setup scripts.

################################################################################
#                              INITIALIZATION
################################################################################

# Determine repo root relative to this file.
COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# COMMON_DIR is lib/bash, so bubble up two levels to reach the repo root.
REPO_ROOT="$(cd "${COMMON_DIR}/../.." && pwd)"

# Mother Box paths (this project's config and data)
PATH_MOTHERBOX_CONFIG="${HOME}/.config/motherbox"
PATH_MOTHERBOX_CONFIG_FILE="${PATH_MOTHERBOX_CONFIG}/config"
PATH_MOTHERBOX_BACKUPS="${PATH_MOTHERBOX_CONFIG}/backups"

################################################################################
#                            LOGGING & DISPLAY
################################################################################
# Provides colored console output for informational, warning, error, and
# success messages. All log functions write to stdout except log_warn and
# log_error which write to stderr.
#
# Functions:
#   log_info <message>     - Blue informational message
#   log_warn <message>     - Yellow warning (stderr)
#   log_error <message>    - Red error (stderr)
#   log_success <message>  - Green success message
#   fail <message>         - Log error and exit 1
#   print_heading <text>   - Cyan section heading
################################################################################

LOG_TAG="setup"

# Color codes for readability.
CLR_RESET=$'\033[0m'    # reset / default
CLR_INFO=$'\033[1;34m'  # bright blue for informational messages
CLR_WARN=$'\033[1;33m'  # bright yellow for warnings
CLR_ERROR=$'\033[1;31m' # bright red for errors
CLR_SUCCESS=$'\033[1;32m' # bright green for success messages
CLR_BOLD=$'\033[1m'     # bold text
CLR_CYAN=$'\033[1;36m'  # bright cyan for headings

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

print_heading() {
  local text="$1"
  printf "\n\033[1;36m==> %s\033[0m\n" "$text"
}

################################################################################
#                         CONFIGURATION MANAGEMENT
################################################################################
# Manages persistent configuration stored in ~/.config/motherbox/config.
# Config file uses shell variable format that can be sourced.
#
# Default values:
#   BACKUP_RETENTION_DAYS=60
#   SETUP_MODE=           (empty, set by run/setup.sh)
#
# Functions:
#   ensure_config              - Create config file with defaults if missing
#   get_config <key>           - Get a config value (stdout)
#   set_config <key> <value>   - Set a config value
################################################################################

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

################################################################################
#                           REQUIREMENT GUARDS
################################################################################
# Guard functions that verify prerequisites are met before proceeding.
# All guards call fail() if the requirement is not satisfied.
#
# Functions:
#   require_command <cmd>      - Ensure binary is in PATH
#   require_file <path>        - Ensure file exists
#   require_directory <path>   - Ensure directory exists
#   check_rosetta              - Check if Rosetta 2 is running (returns 0/1)
#   require_rosetta            - Ensure Rosetta 2 is installed
################################################################################

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    fail "Required command '$cmd' not found in PATH"
  fi
}

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    fail "Required file '$path' is missing"
  fi
}

require_directory() {
  local path="$1"
  if [[ ! -d "$path" ]]; then
    fail "Required directory '$path' is missing"
  fi
}

check_rosetta() {
  if ! pgrep -q oahd; then
    return 1
  fi
  return 0
}

require_rosetta() {
  if ! check_rosetta; then
    log_error "Rosetta 2 is not installed but is required"
    log_info "Install with: softwareupdate --install-rosetta --agree-to-license"
    fail "Rosetta 2 installation required"
  fi
}

################################################################################
#                           BACKUP MANAGEMENT
################################################################################
# Manages file backups in ~/.config/motherbox/backups/.
# Backups are organized by date and app name, with automatic pruning of
# files older than BACKUP_RETENTION_DAYS (default: 60).
#
# Directory structure:
#   ~/.config/motherbox/backups/<YYYYMMDD>/<app_name>/<filename>.<timestamp>
#
# Functions:
#   prune_backups                        - Remove backups older than retention
#   backup_file <path> <app_name>        - Move file to backup location
################################################################################

# prune_backups removes backup files older than BACKUP_RETENTION_DAYS.
# Cleans up empty directories after pruning.
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
# Triggers pruning of backups older than retention period.
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

################################################################################
#                            FILE OPERATIONS
################################################################################
# Functions for creating symlinks and copying files with automatic backup
# of existing files. Use link_file when the target app follows symlinks;
# use copy_file when it doesn't.
#
# Functions:
#   link_file <src> <dest> <app_name>  - Create/update symlink with backup
#   copy_file <src> <dest> <app_name>  - Copy file with backup
################################################################################

# link_file creates or updates a symlink, backing up existing files if needed.
# - If destination is already a correct symlink, does nothing
# - If destination is a different symlink, replaces it (no backup needed)
# - If destination is a regular file, backs it up using backup_file
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
# - If destination is a symlink, removes it and copies
# - If destination is a regular file, backs it up using backup_file
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

################################################################################
#                            SETUP MODE
################################################################################
# Determines and manages the setup mode (work/personal) for the system.
# Mode can come from: command-line flag > config file > interactive prompt.
#
# Functions:
#   prompt_setup_mode              - Interactive prompt for mode selection
#   determine_setup_mode [options] - Resolve mode from all sources
#
# Options for determine_setup_mode:
#   --reset        Ignore saved config, force prompt
#   --unattended   Skip prompting, fail if mode unknown
#   --mode=MODE    Pre-set mode (takes precedence)
################################################################################

# prompt_setup_mode prompts user interactively for setup mode selection.
# Sets SETUP_MODE global variable.
prompt_setup_mode() {
  print_heading "Setup Mode Selection"
  echo "Please select your setup mode:"
  echo "  1) work     - Install work-specific tools & settings"
  echo "  2) personal - Install personal-specific tools & settings"
  echo ""

  while true; do
    read -rp "Enter your choice (1 or 2): " choice
    case $choice in
      1|work)
        SETUP_MODE="work"
        break
        ;;
      2|personal)
        SETUP_MODE="personal"
        break
        ;;
      *)
        echo "Invalid choice. Please enter 1 (work) or 2 (personal)"
        ;;
    esac
  done
}

# determine_setup_mode resolves setup mode from flags, config, or prompt.
# Sets SETUP_MODE global variable and persists to config.
#
# Usage: determine_setup_mode "$@"
#
# Recognized flags: --mode MODE, --reset, --reset-mode, --unattended
# Precedence: --mode flag > config file > interactive prompt
# Returns: 0 on success, 1 if mode could not be determined
#
# Ignores unrecognized arguments, so callers can pass "$@" directly.
determine_setup_mode() {
  local reset_mode=false
  local unattended=false
  local mode_override=""

  # Parse arguments (ignores unrecognized args)
  while [[ $# -gt 0 ]]; do
    case $1 in
      --reset|--reset-mode) reset_mode=true; shift ;;
      --unattended) unattended=true; shift ;;
      --mode) mode_override="${2:-}"; shift 2 ;;
      *) shift ;;
    esac
  done

  # Check command-line override first
  if [[ -n "${mode_override}" ]]; then
    SETUP_MODE="${mode_override}"
  # Check config unless reset requested
  elif [[ "${reset_mode}" != "true" ]]; then
    SETUP_MODE="$(get_config SETUP_MODE)"
  fi

  # Prompt if still not set
  if [[ -z "${SETUP_MODE:-}" ]]; then
    if [[ "${unattended}" == "true" ]]; then
      log_error "Setup mode not set and --unattended prevents prompting"
      log_info "Use --mode=work or --mode=personal to set mode"
      return 1
    fi
    prompt_setup_mode
  fi

  # Persist and report
  set_config SETUP_MODE "${SETUP_MODE}"
  log_info "Setup mode: ${SETUP_MODE}"
  return 0
}

################################################################################
#                               EXPORTS
################################################################################

export REPO_ROOT
export CLR_RESET CLR_INFO CLR_WARN CLR_ERROR CLR_SUCCESS CLR_BOLD CLR_CYAN

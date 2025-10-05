#!/bin/bash
# Common helper functions for setup scripts.

# Determine repo root relative to this file.
COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# COMMON_DIR is lib/bash, so bubble up two levels to reach the repo root.
REPO_ROOT="$(cd "${COMMON_DIR}/../.." && pwd)"

# Setup configuration paths
SETUP_MODE_FILE="${REPO_ROOT}/data/.meta/setup_mode"
ZSHRC_LOCAL="${HOME}/.zshrc.local"

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

# Guard against sourcing multiple times.
export REPO_ROOT

# Export color codes for external use
export CLR_RESET CLR_INFO CLR_WARN CLR_ERROR CLR_SUCCESS CLR_BOLD CLR_CYAN

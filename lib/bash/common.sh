#!/bin/bash
# Common helper functions for setup scripts.

# Determine repo root relative to this file.
COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# COMMON_DIR is lib/bash, so bubble up two levels to reach the repo root.
REPO_ROOT="$(cd "${COMMON_DIR}/../.." && pwd)"
LOG_TAG="setup"

# Color codes for readability.
CLR_RESET=$'\033[0m'   # reset / default
CLR_INFO=$'\033[1;34m' # bright blue for informational messages
CLR_WARN=$'\033[1;33m' # bright yellow for warnings
CLR_ERROR=$'\033[1;31m' # bright red for errors

log_info() {
  printf "%s[%s] %s%s\n" "${CLR_INFO}" "${LOG_TAG}" "$*" "${CLR_RESET}"
}

log_warn() {
  printf "%s[%s] %s%s\n" "${CLR_WARN}" "${LOG_TAG}" "$*" "${CLR_RESET}" >&2
}

log_error() {
  printf "%s[%s] %s%s\n" "${CLR_ERROR}" "${LOG_TAG}" "$*" "${CLR_RESET}" >&2
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

# Guard against sourcing multiple times.
export REPO_ROOT

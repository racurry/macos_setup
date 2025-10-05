#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

# Global flag
SKIP_SUDO=false

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Performs system requirements checks for macOS setup.

OPTIONS:
  --skip-sudo   Skip sudo availability check
  -h, --help    Show this help message and exit

CHECKS PERFORMED:
  - Verifies script is not running as root
  - Validates working directory is repository root
  - Checks required commands (defaults, xcode-select)
  - Checks sudo command availability (unless --skip-sudo)
  - Verifies Xcode Command Line Tools are installed

EXIT CODES:
  0 - All checks passed
  1 - Checks failed
  2 - Manual follow-up required (e.g., Xcode CLT installation in progress)

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --skip-sudo)
      SKIP_SUDO=true
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Error: Unknown option '$1'" >&2
      show_help
      exit 1
      ;;
  esac
done

print_heading "System Requirements Check (MVP)"

# Preflight checks from preflight.sh
log_info "Running preflight checks..."

# Bash stores the effective user ID in $EUID; block running as root.
if [[ $EUID -eq 0 ]]; then
  fail "Run this setup as a regular user, not root"
fi

if [[ "$(pwd)" != "${REPO_ROOT}" ]]; then
  log_info "Changing working directory to ${REPO_ROOT}"
  cd "${REPO_ROOT}"
fi

log_info "Repository root resolved to ${REPO_ROOT}"
log_info "Bash version ${BASH_VERSION}"

require_command defaults

# Conditional sudo check
if [[ "${SKIP_SUDO}" == "false" ]]; then
  require_command sudo
else
  log_warn "Skipping sudo availability check (--skip-sudo flag set)"
fi

log_info "Preflight checks passed"

# Xcode Command Line Tools check from ensure_xcode_clt.sh
log_info "Checking Xcode Command Line Tools..."

require_command xcode-select

if xcode-select -p >/dev/null 2>&1; then
  log_info "Xcode Command Line Tools already installed"
else
  log_info "Triggering Xcode Command Line Tools installation"
  if xcode-select --install; then
    log_info "Installer launched. Complete it, then rerun this step."
    exit 2
  else
    log_warning_message="Installer launch may have failed; verify manually and rerun."
    log_warn "$log_warning_message"
    exit 1
  fi
fi

log_info "All system requirements checks passed"

#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bash/common.sh
source "${SCRIPT_DIR}/../lib/bash/common.sh"

# Global flags
UNATTENDED=false
RESET_MODE=false

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Automated macOS setup script that installs and configures development tools,
applications, and system settings.

OPTIONS:
  --unattended     Skip operations requiring human interaction
  --reset-mode     Ignore saved mode and prompt for selection
  --mode=MODE      Set mode directly (work or personal)
  -h, --help       Show this help message and exit

CONFIGURATION:
  Configuration is persisted to ~/.config/motherbox/config

EXAMPLES:
  # First run
  ./run/setup.sh

  # Override saved mode, persist new mode
  ./run/setup.sh --mode=work

  # Non-interactive setup (skip operations that need you, eg sudo)
  ./run/setup.sh --unattended

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --unattended)
      UNATTENDED=true
      shift
      ;;
    --reset-mode)
      RESET_MODE=true
      shift
      ;;
    --mode=*)
      SETUP_MODE="${1#*=}"
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      fail "Unknown option: $1. Use --help for usage information"
      ;;
  esac
done

# Prompt user for setup mode
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

# Determine setup mode (precedence: flag > config > prompt)
if [[ -z "${SETUP_MODE:-}" ]] && [[ "${RESET_MODE}" != "true" ]]; then
  SETUP_MODE="$(get_config SETUP_MODE)"
fi

if [[ -z "${SETUP_MODE:-}" ]]; then
  prompt_setup_mode
fi

# Persist configuration
set_config SETUP_MODE "${SETUP_MODE}"
log_info "Setup mode: ${SETUP_MODE}"

# Preflight checks
preflight_checks() {
  print_heading "System Requirements Check"
  log_info "Running preflight checks..."

  # Block running as root
  if [[ $EUID -eq 0 ]]; then
    fail "Run this setup as a regular user, not root"
  fi

  if [[ "$(pwd)" != "${REPO_ROOT}" ]]; then
    log_info "Changing working directory to ${REPO_ROOT}"
    cd "${REPO_ROOT}"
  fi

  log_info "Repository root resolved to ${REPO_ROOT}"
  log_info "Bash version ${BASH_VERSION}"

  # Xcode Command Line Tools check
  log_info "Checking Xcode Command Line Tools..."
  if xcode-select -p >/dev/null 2>&1; then
    log_info "Xcode Command Line Tools already installed"
  else
    log_info "Triggering Xcode Command Line Tools installation"
    if xcode-select --install; then
      log_info "Installer launched. Complete it, then rerun this script."
      exit 2
    else
      log_warn "Installer launch may have failed; verify manually and rerun."
      exit 1
    fi
  fi

  log_info "All system requirements checks passed"
}

# Run preflight checks before anything else
preflight_checks

# Build flags for downstream scripts
SUDO_FLAG=""
if [[ "${UNATTENDED}" == "true" ]]; then
  SUDO_FLAG="--unattended"
fi

MODE_FLAG=""
if [[ -n "${SETUP_MODE:-}" ]]; then
  MODE_FLAG="--mode ${SETUP_MODE}"
fi

# Install all the apps - everything else depends on this
STEPS_FOUNDATION=(
  "apps/brew/brew.sh setup ${MODE_FLAG}"
)

# Shell & Security Configuration
STEPS_SHELL=(
  "apps/zsh/zsh.sh setup"
  "apps/git/git.sh setup"
  "apps/ohmyzsh/ohmyzsh.sh setup"
  "apps/direnv/direnv.sh setup"
  "apps/1password/1password.sh setup ${MODE_FLAG}"
)

# Language Runtimes (slow, requires asdf from brew bundle)
STEPS_RUNTIMES=(
  "apps/asdf/asdf.sh setup"
)

# File System Organization
STEPS_FILESYSTEM=(
  "apps/macos/folders.sh setup"
  "apps/icloud/icloud.sh setup"
)

# System Preferences
STEPS_MACOS=(
  "apps/macos/macos.sh setup ${SUDO_FLAG}"
)

# Application Configuration
STEPS_APPS=(
  "apps/claudecode/claudecode.sh setup"
  "apps/shellcheck/shellcheck.sh setup"
  "apps/markdownlint/markdownlint.sh setup"
)

# Run a single step, handling exit codes
run_step() {
  local step="$1"
  set +e
  (cd "${SCRIPT_DIR}" && bash ${step})
  local status=$?
  set -e

  case ${status} in
    0) ;;
    2)
      log_warn "${step} requested manual follow-up; rerun once complete"
      exit 2
      ;;
    *)
      fail "${step} exited with status ${status}"
      ;;
  esac
}

# Run all steps in a phase
run_phase() {
  local phase_name="$1"
  shift
  local steps=("$@")

  print_heading "${phase_name}"
  for step in "${steps[@]}"; do
    run_step "${step}"
  done
}

run_phase "Foundation"      "${STEPS_FOUNDATION[@]}"
run_phase "Shell & Security" "${STEPS_SHELL[@]}"
run_phase "Runtimes"        "${STEPS_RUNTIMES[@]}"
run_phase "File System"     "${STEPS_FILESYSTEM[@]}"
run_phase "macOS Settings"  "${STEPS_MACOS[@]}"
run_phase "Applications"    "${STEPS_APPS[@]}"
manual_file="${SCRIPT_DIR}/../docs/manual_todos.md"
if [[ -f "${manual_file}" ]]; then
  echo
  log_info "Manual checklist: review ${manual_file} for remaining tasks"
fi

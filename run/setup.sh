#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bash/common.sh
source "${SCRIPT_DIR}/../lib/bash/common.sh"

# Save original args to pass through to child scripts
ORIGINAL_ARGS=("$@")

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Automated macOS setup script that installs and configures development tools,
applications, and system settings.

OPTIONS:
  --unattended     Skip operations requiring human interaction
  --reset-mode     Ignore saved mode and prompt for selection
  --mode MODE      Set mode directly (work or personal)
  -h, --help       Show this help message and exit

CONFIGURATION:
  Configuration is persisted to ~/.config/motherbox/config

EXAMPLES:
  # First run
  ./run/setup.sh

  # Override saved mode, persist new mode
  ./run/setup.sh --mode work

  # Non-interactive setup (skip operations that need you, eg sudo)
  ./run/setup.sh --unattended

EOF
}

# Parse command line arguments (only handle --help, rest passed through)
for arg in "$@"; do
  case $arg in
    -h|--help) show_help; exit 0 ;;
  esac
done

# Determine setup mode (precedence: flag > config > prompt)
determine_setup_mode ${ORIGINAL_ARGS[@]+"${ORIGINAL_ARGS[@]}"} || exit 1

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

# Install all the apps - everything else depends on this
STEPS_FOUNDATION=(
  "apps/brew/brew.sh"
)

# Shell & Security Configuration
STEPS_SHELL=(
  "apps/zsh/zsh.sh"
  "apps/git/git.sh"
  "apps/ohmyzsh/ohmyzsh.sh"
  "apps/direnv/direnv.sh"
  "apps/1password/1password.sh"
)

# Language Runtimes (slow, requires asdf from brew bundle)
STEPS_RUNTIMES=(
  "apps/asdf/asdf.sh"
)

# File System Organization
STEPS_FILESYSTEM=(
  "apps/macos/folders.sh"
  "apps/icloud/icloud.sh"
)

# System Preferences
STEPS_MACOS=(
  "apps/macos/macos.sh"
)

# Application Configuration
STEPS_APPS=(
  "apps/claudecode/claudecode.sh"
  "apps/shellcheck/shellcheck.sh"
  "apps/markdownlint/markdownlint.sh"
)

# Run a single step, handling exit codes
# Passes ORIGINAL_ARGS to each script so they receive --mode, --unattended, etc.
run_step() {
  local script="$1"
  set +e
  (cd "${REPO_ROOT}" && bash "${script}" setup ${ORIGINAL_ARGS[@]+"${ORIGINAL_ARGS[@]}"})
  local status=$?
  set -e

  case ${status} in
    0) ;;
    2)
      log_warn "${script} requested manual follow-up; rerun once complete"
      exit 2
      ;;
    *)
      fail "${script} exited with status ${status}"
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

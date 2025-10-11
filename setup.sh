#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/lib/bash/common.sh"

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Automated macOS setup script that installs and configures development tools,
applications, and system settings.

OPTIONS:
  -h, --help    Show this help message and exit

ENVIRONMENT VARIABLES:
  SETUP_MODE    Set to 'work' or 'personal' to install mode-specific packages
                from dotfiles/Brewfile.work or dotfiles/Brewfile.personal
                in addition to the main dotfiles/Brewfile.
                If not set, the script will prompt for selection.

SETUP STEPS:
  1. System requirements check (Xcode CLT, bash version, etc.)
  2. Install Homebrew
  3. Create standard folder structure
  4. Configure iCloud Drive access
  5. Apply macOS system settings (global, input, dock, finder, misc)
  6. Link dotfiles to home directory
  7. Install Homebrew packages from Brewfile(s)
  8. Install asdf plugins and runtimes
  9. Install Oh My Zsh
  10. Configure SSH keys
  11. Install Claude Code CLI

EXIT CODES:
  0 - Success
  1 - Failure
  2 - Manual follow-up required (rerun after completing the action)

EXAMPLES:
  # Run setup interactively (will prompt for mode)
  ./setup.sh

  # Run setup for work environment
  SETUP_MODE=work ./setup.sh

  # Run setup for personal environment
  SETUP_MODE=personal ./setup.sh

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      show_help
      exit 1
      ;;
  esac
done

# Prompt user for setup mode if not already set
prompt_setup_mode() {
  if [[ -n "${SETUP_MODE:-}" ]]; then
    log_info "Setup mode already set to: ${SETUP_MODE}"
    return 0
  fi

  print_heading "Setup Mode Selection"
  echo "Please select your setup mode:"
  echo "  1) work     - Install work-specific packages"
  echo "  2) personal - Install personal-specific packages"
  echo ""

  while true; do
    read -p "Enter your choice (1 or 2): " choice
    case $choice in
      1|work)
        export SETUP_MODE="work"
        log_info "Setup mode set to: work"
        break
        ;;
      2|personal)
        export SETUP_MODE="personal"
        log_info "Setup mode set to: personal"
        break
        ;;
      *)
        echo "Invalid choice. Please enter 1 (work) or 2 (personal)"
        ;;
    esac
  done
}

# Prompt for setup mode before starting
prompt_setup_mode

STEPS=(
  "mvp_system_reqs_check.sh"
  "brew.sh install"
  "folders.sh ${PATH_DOCUMENTS}"
  "icloud.sh"
  "macos_settings.sh global"
  "macos_settings.sh input"
  "macos_settings.sh dock"
  "macos_settings.sh finder"
  "macos_settings.sh misc"
  "dotfiles.sh"
  "brew.sh bundle"
  "asdf.sh plugins"
  "asdf.sh runtimes"
  "oh_my_zsh.sh"
  "ssh.sh"
)

for step in "${STEPS[@]}"; do
  set +e
  (cd "${SCRIPT_DIR}/scripts/bash" && bash ${step})
  status=$?
  set -e

  case ${status} in
    0)
      ;;
    2)
      log_warn "${step} requested manual follow-up; rerun once complete"
      exit 2
      ;;
    *)
      fail "${step} exited with status ${status}"
      ;;
  esac
done
manual_file="${SCRIPT_DIR}/docs/manual_todos.md"
if [[ -f "${manual_file}" ]]; then
  echo
  log_info "Manual checklist: review ${manual_file} for remaining tasks"
fi

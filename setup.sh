#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/lib/bash/common.sh"

# Global flag
SKIP_SUDO=false

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Automated macOS setup script that installs and configures development tools,
applications, and system settings.

OPTIONS:
  --skip-sudo      Skip operations requiring sudo
  --reset-mode     Reset saved work/personal mode and prompt for new selection
  --mode=MODE      Set mode directly (work or personal) without prompting
  -h, --help       Show this help message and exit

ENVIRONMENT VARIABLES:
  SETUP_MODE    Set to 'work' or 'personal' to install mode-specific packages
                from dotfiles/Brewfile.work or dotfiles/Brewfile.personal
                in addition to the main dotfiles/Brewfile.
                If not set, the script will check for a saved mode or prompt.

SETUP STEPS:
  1. System requirements check (Xcode CLT, bash version, etc.)
  2. Install Homebrew
  3. Create standard folder structure
  4. Link dotfiles to home directory
  5. Configure iCloud Drive access
  6. Apply macOS system settings (global, input, dock, finder, misc)
  7. Install Homebrew packages from Brewfile(s)
  8. Install asdf plugins and runtimes
  9. Install Oh My Zsh
  10. Configure SSH keys
  11. Install AI agent tooling

EXIT CODES:
  0 - Success
  1 - Failure
  2 - Manual follow-up required (rerun after completing the action)

EXAMPLES:
  # Run setup interactively (will prompt for mode on first run)
  ./setup.sh

  # Run setup for work environment
  ./setup.sh --mode=work

  # Run setup for personal environment
  ./setup.sh --mode=personal

  # Reset saved mode and prompt again
  ./setup.sh --reset-mode

  # Non-interactive setup (skip sudo operations)
  ./setup.sh --skip-sudo

  # Set mode via environment variable
  SETUP_MODE=work ./setup.sh

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --skip-sudo)
      SKIP_SUDO=true
      shift
      ;;
    --reset-mode)
      rm -f "${SETUP_MODE_FILE}"
      log_info "Setup mode reset - will prompt for new selection"
      shift
      ;;
    --mode=*)
      export SETUP_MODE="${1#*=}"
      if [[ "${SETUP_MODE}" != "work" && "${SETUP_MODE}" != "personal" ]]; then
        fail "Invalid mode: ${SETUP_MODE}. Must be 'work' or 'personal'"
      fi
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

# Prompt user for setup mode if not already set
prompt_setup_mode() {
  # Check if mode already set via environment
  if [[ -n "${SETUP_MODE:-}" ]]; then
    log_info "Setup mode already set to: ${SETUP_MODE}"
    return 0
  fi

  # Try to load from saved file
  if [[ -f "${SETUP_MODE_FILE}" ]]; then
    export SETUP_MODE="$(cat "${SETUP_MODE_FILE}")"
    log_info "Loaded saved setup mode: ${SETUP_MODE}"
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
        break
        ;;
      2|personal)
        export SETUP_MODE="personal"
        break
        ;;
      *)
        echo "Invalid choice. Please enter 1 (work) or 2 (personal)"
        ;;
    esac
  done

  # Save for future runs
  mkdir -p "$(dirname "${SETUP_MODE_FILE}")"
  echo "${SETUP_MODE}" > "${SETUP_MODE_FILE}"
  log_info "Saved setup mode: ${SETUP_MODE}"

  # Add to .zshrc.local
  if ! grep -q "export SETUP_MODE=" "${ZSHRC_LOCAL}" 2>/dev/null; then
    echo "export SETUP_MODE=\"${SETUP_MODE}\"" >> "${ZSHRC_LOCAL}"
    log_info "Added SETUP_MODE to ${ZSHRC_LOCAL}"
  else
    sed -i.bak "s/export SETUP_MODE=.*/export SETUP_MODE=\"${SETUP_MODE}\"/" "${ZSHRC_LOCAL}"
    rm -f "${ZSHRC_LOCAL}.bak"
    log_info "Updated SETUP_MODE in ${ZSHRC_LOCAL}"
  fi
}

# Prompt for setup mode before starting
prompt_setup_mode

# Build sudo flag for scripts
SUDO_FLAG=""
if [[ "${SKIP_SUDO}" == "true" ]]; then
  SUDO_FLAG="--skip-sudo"
fi

STEPS=(
  "mvp_system_reqs_check.sh ${SUDO_FLAG}"
  "brew.sh install"
  "folders.sh ${PATH_DOCUMENTS}"
  "dotfiles.sh"
  "icloud.sh"
  "macos_settings.sh global ${SUDO_FLAG}"
  "macos_settings.sh input ${SUDO_FLAG}"
  "macos_settings.sh dock ${SUDO_FLAG}"
  "macos_settings.sh finder ${SUDO_FLAG}"
  "macos_settings.sh misc ${SUDO_FLAG}"
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

#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/lib/bash/common.sh"

# Global flag
UNATTENDED=false

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Automated macOS setup script that installs and configures development tools,
applications, and system settings.

OPTIONS:
  --unattended     Skip operations requiring sudo
  --reset-mode     Reset saved work/personal mode
  --mode=MODE      Set mode directly (work or personal)
  -h, --help       Show this help message and exit

ENVIRONMENT VARIABLES:
  SETUP_MODE    Set to 'work' or 'personal' to install mode-specific packages
                from apps/brew/Brewfile.work or apps/brew/Brewfile.personal
                in addition to the main apps/brew/Brewfile.
                If not set, the script will prompt for selection.

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
  10. Configure 1Password SSH agent
  11. Install AI agent tooling

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

  # Non-interactive setup (skip sudo operations)
  ./setup.sh --unattended

  # Set mode via command line flag
  ./setup.sh --mode=work

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
      # Reset mode will be handled in prompt_setup_mode
      RESET_MODE=true
      shift
      ;;
    --mode=*)
      export SETUP_MODE="${1#*=}"
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

# Build sudo flag for scripts
SUDO_FLAG=""
if [[ "${UNATTENDED}" == "true" ]]; then
  SUDO_FLAG="--unattended"
fi

STEPS=(
  "scripts/mvp_system_reqs_check.sh ${SUDO_FLAG}"
  "apps/brew/brew.sh install"
  "apps/macos/folders.sh ${PATH_DOCUMENTS}"
  "apps/git/git.sh"
  "apps/zsh/zsh.sh"
  "apps/icloud/icloud.sh"
  "apps/macos/macos.sh global ${SUDO_FLAG}"
  "apps/macos/macos.sh input ${SUDO_FLAG}"
  "apps/macos/macos.sh dock ${SUDO_FLAG}"
  "apps/macos/macos.sh finder ${SUDO_FLAG}"
  "apps/macos/macos.sh misc ${SUDO_FLAG}"
  "apps/brew/brew.sh bundle"
  "apps/asdf/asdf.sh plugins"
  "apps/asdf/asdf.sh runtimes"
  "apps/ohmyzsh/ohmyzsh.sh"
  "apps/1password/1password.sh"
  "apps/claudecode/claudecode.sh"
  "apps/devonthink/devonthink.sh"
  "apps/direnv/direnv.sh"
  "apps/mailmate/mailmate.sh"
  "apps/openscad/openscad.sh"
  "scripts/update_repo.sh"
)

for step in "${STEPS[@]}"; do
  set +e
  (cd "${SCRIPT_DIR}" && bash ${step})
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

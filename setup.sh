#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/lib/bash/common.sh"

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
  "folders.sh"
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

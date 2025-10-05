#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/lib/bash/common.sh"

SETUP_MODE_FILE="${SCRIPT_DIR}/data/.meta/setup_mode"
ZSHRC_LOCAL="${HOME}/.zshrc.local"

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

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
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
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --reset-mode     Reset saved setup mode"
      echo "  --mode=MODE      Set mode directly (work/personal)"
      echo "  --help, -h       Show this help"
      exit 0
      ;;
    *)
      fail "Unknown option: $1. Use --help for usage"
      ;;
  esac
done

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
  "claude_code.sh"
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

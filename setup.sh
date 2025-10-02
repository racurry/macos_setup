#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/lib/bash/common.sh"

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

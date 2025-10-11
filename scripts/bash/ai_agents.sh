#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Create a symlink to the AI coding agents configuration file.

OPTIONS:
  -h, --help    Show this help message and exit

DESCRIPTION:
  This script creates a symbolic link from ~/.ai_agents/AGENTS.md to the
  configuration file in apps/ai_coding/AGENTS.md.

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

print_heading "Configure AI Coding Agents"

AI_AGENTS_DIR="${PATH_AI_AGENTS}"
SRC="${REPO_ROOT}/apps/ai_coding/AGENTS.md"
DEST="${AI_AGENTS_DIR}/AGENTS.md"

require_file "${SRC}"
mkdir -p "${AI_AGENTS_DIR}"

if [[ -L "${DEST}" ]]; then
  current_target="$(readlink "${DEST}")"
  if [[ "${current_target}" == "${SRC}" ]]; then
    log_info "Symlink already correct: ${DEST}"
    exit 0
  fi
  log_info "Removing existing symlink ${DEST}"
  rm "${DEST}"
elif [[ -e "${DEST}" ]]; then
  log_info "Removing existing file ${DEST}"
  rm "${DEST}"
fi

log_info "Linking ${DEST} -> ${SRC}"
ln -s "${SRC}" "${DEST}"

log_info "AI coding agents configured"

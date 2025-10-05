#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Create a symlink to the Claude Code configuration file.

OPTIONS:
  -h, --help    Show this help message and exit

DESCRIPTION:
  This script creates a symbolic link from ~/.claude/CLAUDE.md to the
  Claude Code configuration file in apps/claude_code/CLAUDE.md.

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

print_heading "Configure Claude Code"

CLAUDE_DIR="${HOME}/.claude"
SRC="${REPO_ROOT}/apps/claude_code/CLAUDE.md"
DEST="${CLAUDE_DIR}/CLAUDE.md"

require_file "${SRC}"
mkdir -p "${CLAUDE_DIR}"

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

log_info "Claude Code configured"

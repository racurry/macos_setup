#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Link Claude Code global configuration to ~/.claude.

OPTIONS:
  -h, --help    Show this help message and exit

DESCRIPTION:
  This script creates a symbolic link from apps/claudecode/CLAUDE.global.md
  to ~/.claude/CLAUDE.md.

  - If a symlink already exists at the destination, it will be replaced.
  - If a non-symlink file exists at ~/.claude/CLAUDE.md, it will be backed up
    to ~/.lament-configuration/backups/ with a timestamp suffix.

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

print_heading "Link Claude Code configuration"

RUN_STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_ROOT="${HOME}/.lament-configuration/backups"
mkdir -p "${BACKUP_ROOT}"

# Link CLAUDE.global.md to CLAUDE.md
CLAUDE_GLOBAL_SRC="${REPO_ROOT}/apps/claudecode/CLAUDE.global.md"
CLAUDE_DEST="${HOME}/.claude/CLAUDE.md"

if [[ ! -f "${CLAUDE_GLOBAL_SRC}" ]]; then
  fail "CLAUDE.global.md not found at ${CLAUDE_GLOBAL_SRC}"
fi

# Ensure ~/.claude directory exists
mkdir -p "${HOME}/.claude"

# Handle existing files/symlinks
if [[ -L "${CLAUDE_DEST}" ]]; then
  current_target="$(readlink "${CLAUDE_DEST}")"
  if [[ "${current_target}" == "${CLAUDE_GLOBAL_SRC}" ]]; then
    log_info "Symlink already correct: ${CLAUDE_DEST}"
  else
    log_info "Replacing existing symlink ${CLAUDE_DEST}"
    rm "${CLAUDE_DEST}"
    log_info "Linking ${CLAUDE_DEST} -> ${CLAUDE_GLOBAL_SRC}"
    ln -s "${CLAUDE_GLOBAL_SRC}" "${CLAUDE_DEST}"
  fi
elif [[ -e "${CLAUDE_DEST}" ]]; then
  backup_target="${BACKUP_ROOT}/CLAUDE.md.bak.${RUN_STAMP}"
  log_info "Backing up existing file ${CLAUDE_DEST} to ${backup_target}"
  mv "${CLAUDE_DEST}" "${backup_target}"
  log_info "Linking ${CLAUDE_DEST} -> ${CLAUDE_GLOBAL_SRC}"
  ln -s "${CLAUDE_GLOBAL_SRC}" "${CLAUDE_DEST}"
else
  log_info "Linking ${CLAUDE_DEST} -> ${CLAUDE_GLOBAL_SRC}"
  ln -s "${CLAUDE_GLOBAL_SRC}" "${CLAUDE_DEST}"
fi

# Configure Claude Code settings
SETTINGS_FILE="${HOME}/.claude/settings.json"

log_info "Configuring Claude Code settings"

# Ensure settings file exists
if [[ ! -f "${SETTINGS_FILE}" ]]; then
  log_info "Creating new settings.json file"
  echo '{}' > "${SETTINGS_FILE}"
fi

# Use jq to set alwaysThinkingEnabled and enableAllProjectMcpServers to true
require_command jq

tmp_file=$(mktemp)
jq '.alwaysThinkingEnabled = true | .enableAllProjectMcpServers = true' "${SETTINGS_FILE}" > "${tmp_file}"
mv "${tmp_file}" "${SETTINGS_FILE}"

log_info "Set alwaysThinkingEnabled = true"
log_info "Set enableAllProjectMcpServers = true"

log_success "Claude Code configuration linked successfully"

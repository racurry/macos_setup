#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Link Claude Code configuration files to ~/.claude.

OPTIONS:
  -h, --help    Show this help message and exit

DESCRIPTION:
  This script creates symbolic links for:
  - Hook files from apps/claudecode/hooks to ~/.claude/hooks
  - Command files from apps/claudecode/commands to ~/.claude/commands (recursive)
  - AGENTS.md to ~/.claude/CLAUDE.md

  If a symlink already exists at the destination, it will be replaced. If a
  non-symlink file exists at ~/.claude/CLAUDE.md, it will be backed up to
  ~/.claude/CLAUDE.local.md. Other files are backed up with a timestamp suffix.

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
BACKUP_ROOT="${HOME}/.claude/backups"
mkdir -p "${BACKUP_ROOT}"

# Function to link files recursively from a source directory to a destination directory
# Arguments:
#   $1 - Source directory (absolute path)
#   $2 - Destination directory (absolute path)
#   $3 - Type name (for logging, e.g., "hooks" or "commands")
link_files_recursive() {
  local src_dir="$1"
  local dest_dir="$2"
  local type_name="$3"

  require_directory "${src_dir}"
  mkdir -p "${dest_dir}"

  # Use find to get all files recursively
  while IFS= read -r -d '' src; do
    # Calculate relative path from source directory
    local rel_path="${src#"${src_dir}"/}"
    local dest="${dest_dir}/${rel_path}"
    local dest_parent
    dest_parent="$(dirname "${dest}")"

    # Create parent directory if needed
    mkdir -p "${dest_parent}"

    # Handle existing files/symlinks
    if [[ -L "${dest}" ]]; then
      current_target="$(readlink "${dest}")"
      if [[ "${current_target}" == "${src}" ]]; then
        log_info "Symlink already correct: ${dest}"
        continue
      fi
      log_info "Replacing existing symlink ${dest}"
      rm "${dest}"
    elif [[ -e "${dest}" ]]; then
      # Preserve directory structure in backup
      local backup_rel_path="${rel_path}.bak.${RUN_STAMP}"
      local backup_target="${BACKUP_ROOT}/${type_name}/${backup_rel_path}"
      local backup_parent
      backup_parent="$(dirname "${backup_target}")"
      mkdir -p "${backup_parent}"
      log_info "Backing up existing file ${dest} to ${backup_target}"
      mv "${dest}" "${backup_target}"
    fi

    log_info "Linking ${dest} -> ${src}"
    ln -s "${src}" "${dest}"
  done < <(find "${src_dir}" -type f -print0)

  log_info "Claude Code ${type_name} linked"
}

# Link hooks
HOOKS_SRC_DIR="${REPO_ROOT}/apps/claudecode/hooks"
HOOKS_DEST_DIR="${HOME}/.claude/hooks"
if [[ -d "${HOOKS_SRC_DIR}" ]]; then
  link_files_recursive "${HOOKS_SRC_DIR}" "${HOOKS_DEST_DIR}" "hooks"
fi

# Link commands
COMMANDS_SRC_DIR="${REPO_ROOT}/apps/claudecode/commands"
COMMANDS_DEST_DIR="${HOME}/.claude/commands"
if [[ -d "${COMMANDS_SRC_DIR}" ]]; then
  link_files_recursive "${COMMANDS_SRC_DIR}" "${COMMANDS_DEST_DIR}" "commands"
fi

# Link AGENTS.md to CLAUDE.md
AGENTS_SRC="${REPO_ROOT}/AGENTS.md"
CLAUDE_DEST="${HOME}/.claude/CLAUDE.md"
CLAUDE_LOCAL="${HOME}/.claude/CLAUDE.local.md"

if [[ -f "${AGENTS_SRC}" ]]; then
  if [[ -L "${CLAUDE_DEST}" ]]; then
    current_target="$(readlink "${CLAUDE_DEST}")"
    if [[ "${current_target}" == "${AGENTS_SRC}" ]]; then
      log_info "Symlink already correct: ${CLAUDE_DEST}"
    else
      log_info "Replacing existing symlink ${CLAUDE_DEST}"
      rm "${CLAUDE_DEST}"
      log_info "Linking ${CLAUDE_DEST} -> ${AGENTS_SRC}"
      ln -s "${AGENTS_SRC}" "${CLAUDE_DEST}"
    fi
  elif [[ -e "${CLAUDE_DEST}" ]]; then
    log_info "Backing up existing file ${CLAUDE_DEST} to ${CLAUDE_LOCAL}"
    mv "${CLAUDE_DEST}" "${CLAUDE_LOCAL}"
    log_info "Linking ${CLAUDE_DEST} -> ${AGENTS_SRC}"
    ln -s "${AGENTS_SRC}" "${CLAUDE_DEST}"
  else
    log_info "Linking ${CLAUDE_DEST} -> ${AGENTS_SRC}"
    ln -s "${AGENTS_SRC}" "${CLAUDE_DEST}"
  fi
else
  log_warn "AGENTS.md not found at ${AGENTS_SRC}, skipping"
fi

log_info "All Claude Code configuration files linked"

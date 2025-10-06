#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Link dotfiles from the dotfiles directory to the home directory.

OPTIONS:
  -h, --help    Show this help message and exit

DESCRIPTION:
  This script creates symbolic links for all files in the dotfiles directory
  to the home directory. If a file already exists at the destination, it will
  be backed up to ~/.dotfiles_backup with a timestamp suffix before creating
  the new symlink.

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

print_heading "Link dotfiles"

DOTFILES_DIR="${REPO_ROOT}/dotfiles"
BACKUP_ROOT="${SETUP_PATH_DOTFILES_BACKUP}"
RUN_STAMP="$(date +%Y%m%d_%H%M%S)"

require_directory "${DOTFILES_DIR}"
mkdir -p "${BACKUP_ROOT}"
log_info "Backups will be stored in ${BACKUP_ROOT} with suffix .bak.${RUN_STAMP}"

# include dotfiles in globbing and ignore unmatched globs
shopt -s dotglob nullglob
for src in "${DOTFILES_DIR}"/*; do
  name="$(basename "${src}")"
  [[ "${name}" == "." || "${name}" == ".." ]] && continue
  dest="${HOME}/${name}"

  if [[ -L "${dest}" ]]; then
    current_target="$(readlink "${dest}")"
    if [[ "${current_target}" == "${src}" ]]; then
      log_info "Symlink already correct: ${dest}"
      continue
    fi
    backup_target="${BACKUP_ROOT}/${name}.bak.${RUN_STAMP}"
    log_info "Backing up existing symlink ${dest} to ${backup_target}"
    mv "${dest}" "${backup_target}"
  elif [[ -e "${dest}" ]]; then
    backup_target="${BACKUP_ROOT}/${name}.bak.${RUN_STAMP}"
    log_info "Backing up existing ${dest} to ${backup_target}"
    mv "${dest}" "${backup_target}"
  fi

  log_info "Linking ${dest} -> ${src}"
  ln -s "${src}" "${dest}"
done
shopt -u dotglob nullglob

log_info "Dotfiles linked"

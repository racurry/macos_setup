#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

APPS_DIR="${REPO_ROOT}/apps/zsh"

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Symlink zsh configuration files to home directory.

Files managed:
  .zshrc       - Main zsh configuration
  .galileorc   - Work-specific zsh config

OPTIONS:
  -h, --help    Show this help message and exit
EOF
}

link_file() {
  local src="$1"
  local dest="$2"
  local name
  name="$(basename "$src")"

  if [[ ! -f "$src" ]]; then
    log_warn "Source file not found: $src"
    return 0
  fi

  if [[ -L "$dest" ]]; then
    local current_target
    current_target="$(readlink "$dest")"
    if [[ "$current_target" == "$src" ]]; then
      log_info "$name already linked correctly"
      return 0
    fi
    log_info "Removing existing symlink: $dest"
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    local backup
    backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
    log_warn "Backing up existing $name to $backup"
    mv "$dest" "$backup"
  fi

  ln -s "$src" "$dest"
  log_success "Linked $dest -> $src"
}

main() {
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

  print_heading "Setting up zsh configuration"

  link_file "${APPS_DIR}/.zshrc" "${HOME}/.zshrc"
  link_file "${APPS_DIR}/.galileorc" "${HOME}/.galileorc"

  log_success "Zsh configuration complete"
}

main "$@"

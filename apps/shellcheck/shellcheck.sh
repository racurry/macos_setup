#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
    cat << EOF
Usage: $(basename "$0") <command>

Symlink shellcheckrc from apps/shellcheck/ to ~/.config/shellcheckrc

COMMANDS:
  setup         Create symlink to ~/.config/shellcheckrc
  help          Show this help message

The setup command will:
  1. Create ~/.config/ directory if it doesn't exist
  2. Symlink apps/shellcheck/shellcheckrc to ~/.config/shellcheckrc
EOF
}

setup_shellcheck_config() {
    print_heading "Setup shellcheck configuration"

    local source_file="${SCRIPT_DIR}/shellcheckrc"
    local target_dir="${HOME}/.config"
    local target_file="${target_dir}/shellcheckrc"

    # Verify source file exists
    require_file "${source_file}"

    # Create target directory if it doesn't exist
    if [[ ! -d "${target_dir}" ]]; then
        log_info "Creating ${target_dir}"
        mkdir -p "${target_dir}"
    fi

    # Remove existing symlink or file
    if [[ -L "${target_file}" ]]; then
        log_info "Removing existing symlink"
        rm "${target_file}"
    elif [[ -f "${target_file}" ]]; then
        log_warn "Backing up existing shellcheckrc to shellcheckrc.backup"
        mv "${target_file}" "${target_file}.backup"
    fi

    # Create symlink
    log_info "Symlinking shellcheckrc to ${target_file}"
    ln -s "${source_file}" "${target_file}"
    log_success "Shellcheck configuration symlinked successfully"
}

main() {
    case "${1:-}" in
        setup)
            setup_shellcheck_config
            ;;
        help|--help|-h|"")
            show_help
            exit 0
            ;;
        *)
            echo "Error: Unknown command '${1}'" >&2
            echo
            show_help
            exit 1
            ;;
    esac
}

main "$@"

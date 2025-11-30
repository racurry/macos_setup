#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Symlink .markdownlint-cli2.jsonc from apps/markdownlint/ to ~/.markdownlint-cli2.jsonc

This script will:
  1. Symlink apps/markdownlint/.markdownlint-cli2.jsonc to ~/.markdownlint-cli2.jsonc

OPTIONS:
  -h, --help    Show this help message and exit
EOF
}

setup_markdownlint_config() {
    print_heading "Setup markdownlint configuration"

    local source_file="${SCRIPT_DIR}/.markdownlint-cli2.jsonc"
    local target_file="${HOME}/.markdownlint-cli2.jsonc"

    # Verify source file exists
    require_file "${source_file}"

    # Remove existing symlink or file
    if [[ -L "${target_file}" ]]; then
        log_info "Removing existing symlink"
        rm "${target_file}"
    elif [[ -f "${target_file}" ]]; then
        log_warn "Backing up existing .markdownlint-cli2.jsonc to .markdownlint-cli2.jsonc.backup"
        mv "${target_file}" "${target_file}.backup"
    fi

    # Create symlink
    log_info "Symlinking .markdownlint-cli2.jsonc to ${target_file}"
    ln -s "${source_file}" "${target_file}"
    log_success "Markdownlint configuration symlinked successfully"
}

main() {
    case "${1:-}" in
        help|--help|-h)
            show_help
            exit 0
            ;;
        "")
            setup_markdownlint_config
            ;;
        *)
            echo "Error: Unknown option '${1}'" >&2
            echo
            show_help
            exit 1
            ;;
    esac
}

main "$@"

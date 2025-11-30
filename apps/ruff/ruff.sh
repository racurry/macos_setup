#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Symlink ruff.toml from apps/ruff/ to ~/.config/ruff/ruff.toml

This script will:
  1. Create ~/.config/ruff/ directory if it doesn't exist
  2. Symlink apps/ruff/ruff.toml to ~/.config/ruff/ruff.toml

OPTIONS:
  -h, --help    Show this help message and exit
EOF
}

setup_ruff_config() {
    print_heading "Setup ruff configuration"

    local source_file="${SCRIPT_DIR}/ruff.toml"
    local target_dir="${HOME}/.config/ruff"
    local target_file="${target_dir}/ruff.toml"

    # Verify source file exists
    require_file "${source_file}"

    # Create target directory if it doesn't exist
    if [[ ! -d "${target_dir}" ]]; then
        log_info "Creating ${target_dir}"
        mkdir -p "${target_dir}"
    fi

    link_file "${source_file}" "${target_file}" "ruff"
    log_success "Ruff configuration symlinked successfully"
}

main() {
    case "${1:-}" in
        help|--help|-h)
            show_help
            exit 0
            ;;
        "")
            setup_ruff_config
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

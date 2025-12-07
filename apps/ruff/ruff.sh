#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

APP_NAME="ruff"

show_help() {
    cat <<EOF
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

    link_xdg_config "${SCRIPT_DIR}/ruff.toml" "${APP_NAME}"

    log_success "Ruff configuration symlinked successfully"
}

main() {
    local command=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
        help | --help | -h)
            show_help
            exit 0
            ;;
        setup)
            command="$1"
            shift
            ;;
        *)
            # Check if it's a global flag from run/setup.sh
            if shift_count=$(check_global_flag "$@"); then
                shift "$shift_count"
            else
                log_warn "Ignoring unknown argument: $1"
                shift
            fi
            ;;
        esac
    done

    case "${command}" in
    setup)
        setup_ruff_config
        ;;
    "")
        show_help
        exit 0
        ;;
    esac
}

main "$@"

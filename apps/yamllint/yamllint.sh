#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

APP_NAME="yamllint"

show_help() {
    cat <<EOF
Usage: $(basename "$0") <command>

Symlink yamllint config from apps/yamllint/ to ~/.config/yamllint/config

COMMANDS:
  setup         Create symlink to ~/.config/yamllint/config
  help          Show this help message

The setup command will:
  1. Create ~/.config/yamllint/ directory if it doesn't exist
  2. Symlink apps/yamllint/config to ~/.config/yamllint/config
EOF
}

do_setup() {
    print_heading "Setup yamllint configuration"

    link_xdg_config "${SCRIPT_DIR}/config" "${APP_NAME}"

    log_success "yamllint configuration symlinked successfully"
}

main() {
    local command=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
        setup)
            command="setup"
            shift
            ;;
        help | --help | -h)
            show_help
            exit 0
            ;;
        *)
            log_warn "Ignoring unknown argument: $1"
            shift
            ;;
        esac
    done

    case "${command}" in
    setup)
        do_setup
        ;;
    "")
        show_help
        exit 0
        ;;
    esac
}

main "$@"

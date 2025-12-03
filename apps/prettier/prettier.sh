#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

APP_NAME="prettier"

show_help() {
    cat <<EOF
Usage: $(basename "$0") <command>

Symlink prettier config files from apps/prettier/ to home directory.

COMMANDS:
  setup         Create symlinks to ~/.prettierrc.json5 and ~/.prettierignore
  help          Show this help message
EOF
}

do_setup() {
    print_heading "Setup prettier configuration"

    link_home_dotfile "${SCRIPT_DIR}/.prettierrc.json5" "${APP_NAME}"
    link_home_dotfile "${SCRIPT_DIR}/.prettierignore" "${APP_NAME}"

    log_success "Prettier configuration symlinked successfully"
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

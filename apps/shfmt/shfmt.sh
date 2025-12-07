#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

APP_NAME="shfmt"

show_help() {
    cat <<EOF
Usage: $0 [COMMAND]

Symlink .editorconfig to ~/.editorconfig for shfmt and editor integration.

Commands:
    setup       Symlink .editorconfig to home directory
    help        Show this help message (also: -h, --help)
EOF
}

do_setup() {
    print_heading "Setup ${APP_NAME} configuration"

    link_home_dotfile "${SCRIPT_DIR}/.editorconfig" "${APP_NAME}"

    log_success "EditorConfig symlinked successfully"
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
        do_setup
        ;;
    "")
        show_help
        exit 0
        ;;
    esac
}

main "$@"

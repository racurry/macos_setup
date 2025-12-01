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

    local source_file="${SCRIPT_DIR}/.editorconfig"
    local target_file="${HOME}/.editorconfig"

    require_file "${source_file}"

    link_file "${source_file}" "${target_file}" "${APP_NAME}"
    log_success "EditorConfig symlinked to ${target_file}"
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

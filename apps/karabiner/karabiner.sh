#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

APP_NAME="karabiner"

show_help() {
    cat <<EOF
Usage: $0 [COMMAND]

Symlink Karabiner Elements configuration.

Configuration:
    karabiner.json    Keyboard remapping rules (caps_lock -> hyper key)

Commands:
    setup       Run full setup (primary entry point)
    help        Show this help message (also: -h, --help)
EOF
}

do_setup() {
    print_heading "Setting up Karabiner Elements configuration"

    link_xdg_config "${SCRIPT_DIR}/karabiner.json" "${APP_NAME}"

    log_info "Karabiner Elements configuration complete"
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

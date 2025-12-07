#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
    cat <<EOF
Usage: $0 [COMMAND]

Ensure Xcode Command Line Tools are installed.

Commands:
    setup       Install Xcode CLI tools if not present
    help        Show this help message (also: -h, --help)
EOF
}

do_setup() {
    print_heading "Xcode Command Line Tools"

    if xcode-select -p >/dev/null 2>&1; then
        log_info "Xcode Command Line Tools already installed"
        return 0
    fi

    log_info "Triggering Xcode Command Line Tools installation"
    if xcode-select --install; then
        log_info "Installer launched. Complete it, then rerun this script."
        exit 2
    else
        log_warn "Installer launch may have failed; verify manually and rerun."
        exit 1
    fi
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

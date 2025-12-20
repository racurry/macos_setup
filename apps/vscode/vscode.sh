#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
    cat <<EOF
Usage: $0 [COMMAND]

Visual Studio Code setup.

VSCode installation and extensions are managed in apps/brew/Brewfile.
Preferences sync via VSCode's built-in Settings Sync (sign in with GitHub/Microsoft).

Commands:
    setup       Install VSCode and extensions via Homebrew
    help        Show this help message (also: -h, --help)
EOF
}

do_setup() {
    print_heading "Setting up Visual Studio Code"

    # Install extensions from local Brewfile
    log_info "Installing VSCode extensions..."
    brew bundle --file="${SCRIPT_DIR}/Brewfile"

    log_info "Enable Settings Sync in VSCode to sync preferences across machines"
    log_success "VSCode setup complete"
}

main() {
    local command=""
    local args=("$@")

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
        do_setup "${args[@]}"
        ;;
    "")
        show_help
        exit 0
        ;;
    esac
}

main "$@"

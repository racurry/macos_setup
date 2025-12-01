#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

APPS_DIR="${REPO_ROOT}/apps/zsh"
APP_NAME="zsh"

show_help() {
    cat << EOF
Usage: $0 [COMMAND]

Symlink zsh configuration files to home directory.

Files managed:
    .zshrc       - Main zsh configuration
    .galileorc   - Work-specific zsh config

Commands:
    setup       Run full setup (symlink configuration files)
    help        Show this help message (also: -h, --help)
EOF
}

do_setup() {
    print_heading "Setting up zsh configuration"

    link_file "${APPS_DIR}/.zshrc" "${HOME}/.zshrc" "${APP_NAME}"
    link_file "${APPS_DIR}/.galileorc" "${HOME}/.galileorc" "${APP_NAME}"

    log_success "Zsh configuration complete"
}

main() {
    local command=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            help|--help|-h)
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

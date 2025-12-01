#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

APP_NAME="git"
APPS_DIR="${REPO_ROOT}/apps/${APP_NAME}"

show_help() {
    cat << EOF
Usage: $0 [COMMAND]

Symlink git configuration files to home directory.

Files managed:
    .gitconfig          Main git configuration
    .gitignore_global   Global gitignore patterns
    .gitconfig_galileo  Work-specific git config (if present)

Commands:
    setup       Run full setup (primary entry point)
    help        Show this help message (also: -h, --help)
EOF
}

link_git_file() {
    local src="$1"
    local dest="$2"

    if [[ ! -f "$src" ]]; then
        log_warn "Source file not found: $src"
        return 0
    fi

    link_file "$src" "$dest" "$APP_NAME"
}

do_setup() {
    print_heading "Setting up git configuration"

    link_git_file "${APPS_DIR}/.gitconfig" "${HOME}/.gitconfig"
    link_git_file "${APPS_DIR}/.gitignore_global" "${HOME}/.gitignore_global"

    # Link work-specific config if present
    if [[ -f "${APPS_DIR}/.gitconfig_galileo" ]]; then
        link_git_file "${APPS_DIR}/.gitconfig_galileo" "${HOME}/.gitconfig_galileo"
    fi

    log_info "Git configuration complete"
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

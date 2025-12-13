#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

APP_NAME="markdownlint"

show_help() {
    cat <<EOF
Usage: $(basename "$0") <command>

Symlink .markdownlint-cli2.jsonc from apps/markdownlint/ to ~/.markdownlint-cli2.jsonc

COMMANDS:
  setup         Create symlink to ~/.markdownlint-cli2.jsonc
  help          Show this help message
EOF
}

do_setup() {
    print_heading "Setup markdownlint configuration"

    # Installed via Brewfile; verify it's available
    require_command markdownlint-cli2

    link_home_dotfile "${SCRIPT_DIR}/.markdownlint-cli2.jsonc" "${APP_NAME}"

    log_success "Markdownlint configuration symlinked successfully"
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

#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [COMMAND]

Install Oh My Zsh shell framework if not already present.

Commands:
    setup       Run full setup (primary entry point)
    help        Show this help message (also: -h, --help)

Description:
    This script checks if Oh My Zsh is already installed in ~/.oh-my-zsh.
    If not present, it downloads and installs Oh My Zsh using the official
    installer script with safe defaults (no shell change, keep existing .zshrc).

EOF
}

do_setup() {
    print_heading "Ensure shell framework"

    if [[ -d "${HOME}/.oh-my-zsh" ]]; then
        log_info "Oh My Zsh already installed"
        return 0
    fi

    require_command curl

    log_info "Installing Oh My Zsh"
    if RUNZSH=no KEEP_ZSHRC=yes CHSH=no \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" >/dev/null; then
        log_info "Oh My Zsh installed. Open a new shell session to pick it up."
    else
        fail "Oh My Zsh installer failed"
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

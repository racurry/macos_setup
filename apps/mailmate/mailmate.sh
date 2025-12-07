#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

APP_NAME="mailmate"

show_help() {
    cat <<EOF
Usage: $0 [COMMAND]

Configure MailMate keybindings and preferences.

Commands:
    setup       Run full setup (primary entry point)
    help        Show this help message (also: -h, --help)
EOF
}

do_setup() {
    print_heading "Setting up MailMate keybindings and preferences"

    local source_plist="${SCRIPT_DIR}/MotherBox.plist"
    local target_dir="/Applications/MailMate.app/Contents/Resources/KeyBindings"
    local target_plist="${target_dir}/MotherBox.plist"

    require_file "${source_plist}"

    if [[ ! -d "/Applications/MailMate.app" ]]; then
        fail "MailMate.app not found in /Applications"
    fi

    mkdir -p "${target_dir}"
    copy_file "${source_plist}" "${target_plist}" "${APP_NAME}"

    log_info "Setting MmMessagesOutlineMoveStrategy to 'previous'"
    defaults write com.freron.MailMate MmMessagesOutlineMoveStrategy -string "previous"

    log_success "MailMate configuration complete"
    log_info "Note: You may need to restart MailMate for changes to take effect"
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

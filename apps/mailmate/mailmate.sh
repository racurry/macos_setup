#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
    cat << EOF
Usage: $0 [COMMAND]

Configure MailMate keybindings and preferences.

Commands:
    install     Install custom keybindings and set preferences
    --help      Show this help message

If no command is specified, install will be run.

EOF
}

install_keybindings() {
    print_heading "Installing MailMate keybindings and preferences"

    local source_plist="${REPO_ROOT}/apps/mailmate/Pumpkin.plist"
    local target_dir="/Applications/MailMate.app/Contents/Resources/KeyBindings"
    local target_plist="${target_dir}/Pumpkin.plist"

    # Verify source file exists
    require_file "${source_plist}"

    # Check if MailMate is installed
    if [[ ! -d "/Applications/MailMate.app" ]]; then
        fail "MailMate.app not found in /Applications"
    fi

    # Create target directory if it doesn't exist
    if [[ ! -d "${target_dir}" ]]; then
        log_info "Creating KeyBindings directory: ${target_dir}"
        mkdir -p "${target_dir}"
    fi

    # Copy keybindings file
    log_info "Copying Pumpkin.plist to ${target_plist}"
    cp "${source_plist}" "${target_plist}"

    # Set message selection strategy
    # For inbox sorted with newest at top, "previous" means select older message after delete/archive
    log_info "Setting MmMessagesOutlineMoveStrategy to 'previous'"
    defaults write com.freron.MailMate MmMessagesOutlineMoveStrategy -string "previous"

    log_info "✓ MailMate configuration complete"
    log_info "  - Keybindings: ${target_plist}"
    log_info "  - Move strategy: previous (selects older message after delete/archive)"
    log_info ""
    log_info "Note: You may need to restart MailMate for changes to take effect"
}

main() {
    case "${1:-}" in
        install)
            install_keybindings
            ;;
        help|--help|-h)
            show_help
            exit 0
            ;;
        "")
            install_keybindings
            ;;
        *)
            echo "Error: Unknown command '${1}'"
            echo
            show_help
            exit 1
            ;;
    esac
}

main "$@"

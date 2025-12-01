#!/bin/bash
# Alfred configuration
# Sets hotkey and appearance defaults via defaults write commands

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

# Domains
DOMAIN_PREFS="com.runningwithcrayons.Alfred-Preferences"

show_help() {
    cat <<EOF
Usage: $0 [COMMAND]

Configure Alfred settings via defaults write.

Commands:
    setup       Run full setup (primary entry point)
    show        Display current Alfred settings
    help        Show this help message (also: -h, --help)

What this script does:
    - Sets default hotkey to Ctrl+Opt+Space
    - Sets appearance theme to Yosemite

Note:
    Alfred should be quit before running this script for changes to take effect.
    Manual setup steps (permissions, sync, license) are documented in README.md.
EOF
}

check_alfred_running() {
    if pgrep -x "Alfred" >/dev/null 2>&1; then
        log_warn "Alfred is running. Changes may not take effect until Alfred is restarted."
        return 0
    fi
    return 0
}

do_setup() {
    print_heading "Configuring Alfred"

    require_command defaults

    check_alfred_running

    # Set hotkey to Ctrl+Opt+Space (key 49 = Space, mod 786432 = Ctrl+Opt)
    log_info "Setting hotkey to Ctrl+Opt+Space"
    defaults write "${DOMAIN_PREFS}" hotkey.default -dict-add key 49
    defaults write "${DOMAIN_PREFS}" hotkey.default -dict-add mod 786432
    defaults write "${DOMAIN_PREFS}" hotkey.default -dict-add string "Space"

    # Set appearance theme
    log_info "Setting appearance theme to Yosemite"
    defaults write "${DOMAIN_PREFS}" appearance.theme -string "alfred.theme.yosemite"

    log_success "Alfred configuration complete"
    log_info ""
    log_info "Manual setup steps required:"
    log_info "  1. Grant Accessibility permission in System Settings"
    log_info "  2. Configure sync location (Alfred Preferences > Advanced)"
    log_info "  3. Activate Powerpack license if applicable"
    log_info "  4. Optionally disable Spotlight shortcut if desired"
    log_info ""
    log_info "See apps/alfred/README.md for detailed instructions."
}

do_show() {
    print_heading "Current Alfred Settings"

    if ! defaults read "${DOMAIN_PREFS}" >/dev/null 2>&1; then
        log_warn "No Alfred preferences found. Alfred may not be installed or configured."
        return 0
    fi

    echo "Hotkey:"
    defaults read "${DOMAIN_PREFS}" hotkey.default 2>/dev/null || echo "  (not set)"
    echo ""

    echo "Appearance theme:"
    defaults read "${DOMAIN_PREFS}" appearance.theme 2>/dev/null || echo "  (not set)"
    echo ""

    echo "Sync folder (from main domain):"
    defaults read com.runningwithcrayons.Alfred syncfolder 2>/dev/null || echo "  (not set)"
}

main() {
    local command=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
        help | --help | -h)
            show_help
            exit 0
            ;;
        setup | show)
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
    show)
        do_show
        ;;
    "")
        show_help
        exit 0
        ;;
    esac
}

main "$@"

#!/bin/bash
# Kitty terminal configuration
# Links configuration files to ~/.config/kitty/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

KITTY_CONFIG_DIR="${HOME}/.config/kitty"

show_help() {
    cat <<EOF
Usage: $0 [COMMAND]

Configure Kitty terminal settings.

Commands:
    setup       Run full setup (primary entry point)
    show        Display current Kitty configuration
    help        Show this help message (also: -h, --help)

What this script does:
    - Links kitty.conf from this repo to ~/.config/kitty/
    - Creates config directory if it doesn't exist

Configuration files:
    - kitty.conf: Main configuration file
EOF
}

do_setup() {
    print_heading "Configuring Kitty"

    # Create config directory if needed
    if [[ ! -d "${KITTY_CONFIG_DIR}" ]]; then
        log_info "Creating Kitty config directory"
        mkdir -p "${KITTY_CONFIG_DIR}"
    fi

    # Link configuration files
    if [[ -f "${SCRIPT_DIR}/kitty.conf" ]]; then
        link_file "${SCRIPT_DIR}/kitty.conf" "${KITTY_CONFIG_DIR}/kitty.conf" "kitty"
    else
        log_info "No kitty.conf found in ${SCRIPT_DIR}"
        log_info "Create kitty.conf to have it linked during setup"
    fi

    log_success "Kitty configuration complete"
}

do_show() {
    print_heading "Current Kitty Settings"

    echo "Config directory: ${KITTY_CONFIG_DIR}"
    if [[ -d "${KITTY_CONFIG_DIR}" ]]; then
        echo "  Status: exists"
        echo ""
        echo "Configuration files:"
        ls -la "${KITTY_CONFIG_DIR}/" 2>/dev/null || echo "  (empty)"
    else
        echo "  Status: not created"
    fi

    echo ""
    if [[ -f "${KITTY_CONFIG_DIR}/kitty.conf" ]]; then
        echo "kitty.conf preview (first 20 lines):"
        head -20 "${KITTY_CONFIG_DIR}/kitty.conf"
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
        setup | show)
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

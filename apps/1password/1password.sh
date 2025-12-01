#!/bin/bash
# 1Password SSH agent configuration
# Copies the appropriate agent.toml based on mode (work or personal)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

APPS_DIR="${REPO_ROOT}/apps/1password"
CONFIG_DIR="${HOME}/.config/1password/ssh"
AGENT_TOML="${CONFIG_DIR}/agent.toml"

show_help() {
    cat << EOF
Usage: $(basename "$0") [COMMAND] [OPTIONS]

Configure 1Password SSH agent.

Commands:
    setup       Run full setup (primary entry point)
    show        Display current agent.toml
    help        Show this help message (also: -h, --help)

Options:
    --mode MODE     Set mode to 'work' or 'personal'
    --unattended    Skip prompts, fail if mode unknown
EOF
}

do_setup() {
    print_heading "Configuring 1Password SSH agent"

    local source_file="${APPS_DIR}/agent.${SETUP_MODE}.toml"

    require_file "${source_file}"

    mkdir -p "${CONFIG_DIR}"

    link_file "${source_file}" "${AGENT_TOML}" "1password"

    log_success "1Password SSH agent configured"
    echo ""
    cat "${AGENT_TOML}"
}

do_show() {
    if [[ -f "${AGENT_TOML}" ]]; then
        cat "${AGENT_TOML}"
    else
        log_warn "No agent.toml found at ${AGENT_TOML}"
    fi
}

main() {
    local command=""
    local args=("$@")

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --mode) shift 2 ;;
            --unattended) shift ;;
            help|--help|-h) show_help; exit 0 ;;
            setup|show) command="$1"; shift ;;
            *) log_warn "Ignoring unknown argument: $1"; shift ;;
        esac
    done

    case "${command}" in
        setup)
            determine_setup_mode "${args[@]}" || exit 1
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

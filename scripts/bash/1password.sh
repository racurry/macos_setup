#!/bin/bash
# 1Password SSH agent configuration
# Copies the appropriate agent.toml based on SETUP_MODE

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

APPS_DIR="${REPO_ROOT}/apps/1password"
CONFIG_DIR="${HOME}/.config/1password/ssh"
AGENT_TOML="${CONFIG_DIR}/agent.toml"

show_usage() {
    cat << EOF
Usage: $(basename "$0") [command]

Configure 1Password SSH agent.

Commands:
    setup [work|personal]  - Copy agent.toml (default: personal)
    show                   - Display current agent.toml
    help                   - Show this help

Environment:
    SETUP_MODE             - Set to 'work' or 'personal' (overridden by command args)
EOF
}

setup_agent_toml() {
    local mode="${1:-${SETUP_MODE:-personal}}"

    print_heading "Configuring 1Password SSH agent"

    log_info "Mode: ${mode}"

    local source_file="${APPS_DIR}/agent.${mode}.toml"

    if [[ ! -f "${source_file}" ]]; then
        fail "Source file not found: ${source_file}"
    fi

    mkdir -p "${CONFIG_DIR}"
    log_info "Created ${CONFIG_DIR}"

    # Remove existing file/symlink if present
    if [[ -e "${AGENT_TOML}" || -L "${AGENT_TOML}" ]]; then
        rm "${AGENT_TOML}"
    fi

    ln -s "${source_file}" "${AGENT_TOML}"

    log_success "Linked ${AGENT_TOML} -> ${source_file}"
    echo ""
    cat "${AGENT_TOML}"
}

show_config() {
    if [[ -f "${AGENT_TOML}" ]]; then
        cat "${AGENT_TOML}"
    else
        log_warn "No agent.toml found at ${AGENT_TOML}"
    fi
}

main() {
    local command="setup"
    local mode_arg=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help|help)
                show_usage
                exit 0
                ;;
            setup|show)
                command="$1"
                shift
                if [[ $# -gt 0 && ($1 == "work" || $1 == "personal") ]]; then
                    mode_arg="$1"
                    shift
                fi
                ;;
            work|personal)
                mode_arg="$1"
                shift
                ;;
            *)
                log_error "Unknown argument: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    case "$command" in
        setup)
            setup_agent_toml "$mode_arg"
            ;;
        show)
            show_config
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

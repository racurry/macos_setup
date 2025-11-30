#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
    cat << EOF
Usage: $0 [COMMAND] [OPTIONS]

Link Claude Code global configuration to ~/.claude.

Commands:
    setup       Run full setup (primary entry point)
    help        Show this help message (also: -h, --help)

Description:
    This script creates symbolic links for Claude Code global configuration:
    - apps/claudecode/CLAUDE.global.md -> ~/.claude/CLAUDE.md
    - apps/claudecode/AGENTS.global.md -> ~/AGENTS.md

    It also configures Claude Code settings.

    - If a symlink already exists at a destination, it will be replaced.
    - If a non-symlink file exists at a destination, it will be backed up
      to ~/.config/motherbox/backups/ with a timestamp suffix.
EOF
}

do_setup() {
    print_heading "Link Claude Code configuration"

    # Link CLAUDE.global.md to ~/.claude/CLAUDE.md
    local claude_global_src="${REPO_ROOT}/apps/claudecode/CLAUDE.global.md"
    local claude_dest="${HOME}/.claude/CLAUDE.md"
    require_file "${claude_global_src}"
    mkdir -p "${HOME}/.claude"
    link_file "${claude_global_src}" "${claude_dest}"

    # Link AGENTS.global.md to ~/AGENTS.md
    local agents_global_src="${REPO_ROOT}/apps/claudecode/AGENTS.global.md"
    local agents_dest="${HOME}/AGENTS.md"
    require_file "${agents_global_src}"
    link_file "${agents_global_src}" "${agents_dest}"

    # Configure Claude Code settings
    local settings_file="${HOME}/.claude/settings.json"

    log_info "Configuring Claude Code settings"

    # Ensure settings file exists
    if [[ ! -f "${settings_file}" ]]; then
        log_info "Creating new settings.json file"
        echo '{}' > "${settings_file}"
    fi

    # Use jq to set alwaysThinkingEnabled and enableAllProjectMcpServers to true
    require_command jq

    local tmp_file
    tmp_file=$(mktemp)
    jq '.alwaysThinkingEnabled = true | .enableAllProjectMcpServers = true' "${settings_file}" > "${tmp_file}"
    mv "${tmp_file}" "${settings_file}"

    log_info "Set alwaysThinkingEnabled = true"
    log_info "Set enableAllProjectMcpServers = true"

    log_success "Claude Code configuration linked successfully"
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
                echo "Error: Unknown argument '${1}'" >&2
                echo
                show_help
                exit 1
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

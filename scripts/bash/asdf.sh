#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
    cat << EOF
Usage: $0 [COMMAND]

Manage asdf plugins and runtime installations.

Commands:
    plugins     Add asdf plugins based on .tool-versions file
    runtimes    Install asdf runtimes based on .tool-versions file
    --help      Show this help message

If no command is specified, both plugins and runtimes will be processed.
EOF
}

add_plugins() {
    print_heading "Add asdf plugins"

    require_command asdf

    # Get plugin list from asdf's current command (relies on asdf finding .tool-versions)
    plugin_list=$(asdf current --no-header 2>/dev/null | awk '{print $1}' || true)
    if [[ -z "${plugin_list}" ]]; then
        log_info "No tools configured for asdf"
        return 0
    fi

    while IFS= read -r plugin; do
        [[ -n "${plugin}" ]] || continue
        log_info "Adding '${plugin}'"
        asdf plugin add "${plugin}"
    done <<< "${plugin_list}"
}

install_runtimes() {
    print_heading "Install asdf runtimes"

    require_command asdf

    log_info "Running 'asdf install'"
    unset ASDF_RUBY_VERSION ASDF_NODEJS_VERSION ASDF_PYTHON_VERSION
    asdf install
}

main() {
    case "${1:-}" in
        plugins)
            add_plugins
            ;;
        runtimes)
            install_runtimes
            ;;
        help|--help|-h)
            show_help
            exit 0
            ;;
        "")
            show_help
            exit 0
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
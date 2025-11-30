#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
    cat << EOF
Usage: $0 [COMMAND]

Manage DEVONthink AppleScript compilation and deployment.

Commands:
    watch       Watch for changes and auto-compile scripts
    deploy      Watch for changes and auto-compile + deploy scripts
    --help      Show this help message

If no command is specified, watch will be run.

EOF
}

watch_and_compile() {
    print_heading "Watch DEVONthink scripts (compile only)"

    require_command entr
    require_command make

    local devonthink_dir="${REPO_ROOT}/apps/devonthink"
    require_directory "${devonthink_dir}"
    require_directory "${devonthink_dir}/src"

    log_info "Watching for changes in ${devonthink_dir}/src..."
    log_info "Scripts will be compiled to ${devonthink_dir}/build/"
    log_info "Press Ctrl+C to stop"

    find "${devonthink_dir}/src" -name "*.applescript" | entr -r sh -c "cd '${devonthink_dir}' && make all"
}

watch_and_deploy() {
    print_heading "Watch DEVONthink scripts (compile + deploy)"

    require_command entr
    require_command make

    local devonthink_dir="${REPO_ROOT}/apps/devonthink"
    require_directory "${devonthink_dir}"
    require_directory "${devonthink_dir}/src"

    log_info "Watching for changes in ${devonthink_dir}/src..."
    log_info "Scripts will be compiled and deployed to DEVONthink"
    log_info "Press Ctrl+C to stop"

    find "${devonthink_dir}/src" -name "*.applescript" | entr -r sh -c "cd '${devonthink_dir}' && make deploy"
}

main() {
    case "${1:-}" in
        watch)
            watch_and_compile
            ;;
        deploy)
            watch_and_deploy
            ;;
        help|--help|-h)
            show_help
            exit 0
            ;;
        "")
            watch_and_compile
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
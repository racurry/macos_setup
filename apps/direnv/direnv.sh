#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

APPS_DIR="${REPO_ROOT}/apps/direnv"
APP_NAME="direnv"

show_help() {
    cat << EOF
Usage: $0 [COMMAND]

Symlink direnv library files from apps/direnv/ to ~/.config/direnv/lib/

This script will:
  1. Create ~/.config/direnv/lib/ directory if it doesn't exist
  2. Symlink library .sh files (excluding direnv.sh) to ~/.config/direnv/lib/

Commands:
    setup       Run full setup (symlink library files)
    help        Show this help message (also: -h, --help)
EOF
}

do_setup() {
    print_heading "Setting up direnv library files"

    require_command direnv

    local target_dir="${HOME}/.config/direnv/lib"

    # Create target directory if it doesn't exist
    if [[ ! -d "${target_dir}" ]]; then
        log_info "Creating ${target_dir}"
        mkdir -p "${target_dir}"
    fi

    # Find and symlink all library .sh files (excluding this script)
    for source_file in "${APPS_DIR}"/*.sh; do
        # Check if glob matched anything
        [[ -e "${source_file}" ]] || continue

        local filename
        filename="$(basename "${source_file}")"

        # Skip the setup script itself
        [[ "${filename}" == "direnv.sh" ]] && continue

        local target_file="${target_dir}/${filename}"
        link_file "${source_file}" "${target_file}" "${APP_NAME}"
    done

    log_success "direnv library setup complete"
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
                fail "Unknown argument '${1}'. Run '$0 help' for usage."
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

#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

# Paths used by this script
PATH_DOCUMENTS="${HOME}/Documents"

show_help() {
    cat << EOF
Usage: $0 [COMMAND]

Create organizational folder structure in Documents directory.

Commands:
    setup       Run full setup (primary entry point)
    help        Show this help message (also: -h, --help)

Folders created in ${PATH_DOCUMENTS}:
    @auto           Automated/scripted content
    000_Inbox       Incoming items to be processed
    100_Life        Personal life organization
    150_Projects    Active projects
    200_People      People-related information
    400_Topics      Topic-based resources
    700_Libraries   Reference materials
    800_Posterity   Long-term archival
    999_Meta        Meta information about the system

Examples:
    $0 setup    # Create folder structure in Documents
EOF
}

do_setup() {
    print_heading "Make folders how I like em"

    log_info "Parent directory: ${PATH_DOCUMENTS}"

    # Create parent directory if needed
    if [[ ! -d "${PATH_DOCUMENTS}" ]]; then
        log_info "Creating parent directory: ${PATH_DOCUMENTS}"
        mkdir -p "${PATH_DOCUMENTS}"
    fi

    local folders=(
        "@auto"
        "000_Inbox"
        "100_Life"
        "150_Projects"
        "200_People"
        "400_Topics"
        "700_Libraries"
        "800_Posterity"
        "999_Meta"
    )

    local folder target
    for folder in "${folders[@]}"; do
        target="${PATH_DOCUMENTS}/${folder}"
        if [[ -d "${target}" ]]; then
            log_info "Folder already exists: ${target}"
        else
            log_info "Creating folder: ${target}"
            mkdir -p "${target}"
        fi
    done

    log_info "Created the folders we like"
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

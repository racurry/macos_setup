#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
    cat << EOF
Usage: $0

Symlink direnv library files from apps/direnv/ to ~/.config/direnv/lib/

This script will:
  1. Create ~/.config/direnv/lib/ directory if it doesn't exist
  2. Symlink all .sh files from apps/direnv/ to ~/.config/direnv/lib/
EOF
}

setup_direnv_lib() {
    print_heading "Setup direnv library files"

    require_command direnv

    local source_dir="${SCRIPT_DIR}/../../apps/direnv"
    local target_dir="${HOME}/.config/direnv/lib"

    # Create target directory if it doesn't exist
    if [[ ! -d "${target_dir}" ]]; then
        log_info "Creating ${target_dir}"
        mkdir -p "${target_dir}"
    fi

    # Find and symlink all .sh files
    if [[ ! -d "${source_dir}" ]]; then
        log_warn "Source directory ${source_dir} does not exist, skipping"
        return 0
    fi

    local file_count=0
    for source_file in "${source_dir}"/*.sh; do
        # Check if glob matched anything
        [[ -e "${source_file}" ]] || continue

        local filename=$(basename "${source_file}")
        local target_file="${target_dir}/${filename}"

        # Remove existing symlink or file
        if [[ -L "${target_file}" ]] || [[ -f "${target_file}" ]]; then
            log_info "Removing existing ${filename}"
            rm "${target_file}"
        fi

        log_info "Symlinking ${filename}"
        ln -s "${source_file}" "${target_file}"
        ((file_count++))
    done

    if [[ ${file_count} -eq 0 ]]; then
        log_info "No .sh files found in ${source_dir}"
    else
        log_info "Symlinked ${file_count} direnv library file(s)"
    fi
}

main() {
    case "${1:-}" in
        help|--help|-h)
            show_help
            exit 0
            ;;
        "")
            setup_direnv_lib
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

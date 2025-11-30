#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
    cat << EOF
Usage: $(basename "$0") <command>

Symlink .markdownlint-cli2.jsonc from apps/markdownlint/ to ~/.markdownlint-cli2.jsonc

COMMANDS:
  setup         Create symlink to ~/.markdownlint-cli2.jsonc
  help          Show this help message
EOF
}

do_setup() {
    print_heading "Setup markdownlint configuration"

    local source_file="${SCRIPT_DIR}/.markdownlint-cli2.jsonc"
    local target_file="${HOME}/.markdownlint-cli2.jsonc"

    require_file "${source_file}"
    link_file "${source_file}" "${target_file}" "markdownlint"
    log_success "Markdownlint configuration symlinked successfully"
}

main() {
    case "${1:-}" in
        setup)
            do_setup
            ;;
        help|--help|-h|"")
            show_help
            exit 0
            ;;
        *)
            fail "Unknown command '${1}'. Run '$0 help' for usage."
            ;;
    esac
}

main "$@"

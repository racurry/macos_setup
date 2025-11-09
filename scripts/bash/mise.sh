#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
    cat << EOF
Usage: $0 [COMMAND]

Manage mise and runtime installations.

Commands:
    install     Install mise and configure it
    runtimes    Install runtimes based on .tool-versions file
    --help      Show this help message

If no command is specified, both installation and runtimes will be processed.
EOF
}

install_mise() {
    print_heading "Install and configure mise"

    require_command mise

    log_info "Activating mise for bash/zsh"
    # mise is already installed via Homebrew
    # Configuration will be done in shell init files

    log_info "Configuring mise settings"
    # Enable mise to use .tool-versions files (compatible with asdf)
    mise settings set experimental true
    mise settings set legacy_version_file true
    mise settings set always_keep_download false
    mise settings set always_keep_install false

    # Set up default package configs
    MISE_CONFIG_DIR="${HOME}/.config/mise"
    APPS_MISE_DIR="${SCRIPT_DIR}/../../apps/mise"

    mkdir -p "${MISE_CONFIG_DIR}"

    # Link default package files if they exist
    for file in .default-python-packages .default-gems .default-npm-packages; do
        if [[ -f "${APPS_MISE_DIR}/${file}" ]]; then
            log_info "Linking ${file}"
            ln -sf "${APPS_MISE_DIR}/${file}" "${MISE_CONFIG_DIR}/${file}"
        fi
    done

    log_info "mise installation and configuration complete"
}

install_runtimes() {
    print_heading "Install mise runtimes"

    require_command mise

    log_info "Running 'mise install'"
    # Unset legacy Intel Mac build flags that may interfere with Apple Silicon builds
    # mise/ruby-build will automatically detect the correct paths for Homebrew dependencies
    unset LDFLAGS CPPFLAGS PKG_CONFIG_PATH
    mise install
}

main() {
    case "${1:-}" in
        install)
            install_mise
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

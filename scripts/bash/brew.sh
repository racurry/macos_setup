#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
    cat << EOF
Usage: $0 [COMMAND]

Manage Homebrew installation and package management.

Commands:
    install     Install Homebrew if not already installed
    bundle      Install packages from Brewfile(s)
    --help      Show this help message

If no command is specified, both install and bundle will be processed.

Environment Variables:
    SETUP_MODE  Set to 'work' or 'personal' to install mode-specific packages
                from dotfiles/Brewfile.work or dotfiles/Brewfile.personal
                in addition to the main dotfiles/Brewfile
EOF
}

install_homebrew() {
    print_heading "Install Homebrew"

    require_command curl

    brew_path="/opt/homebrew/bin/brew"
    if [[ -x "${brew_path}" ]]; then
        # Homebrew is already installed; but is it sourced?
        if command -v brew >/dev/null 2>&1; then
            log_info "Homebrew already installed"
            return 0
        fi
        eval "$(${brew_path} shellenv)"
        if command -v brew >/dev/null 2>&1; then
            log_info "Homebrew installed, but not sourced; environment updated for this shell"
            return 0
        fi
    fi

    log_info "Installing Homebrew"
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        log_warn "Homebrew installer completed. Configure your shell environment, then rerun setup."
        log_warn "Add this to your shell profile (and run it in the current shell):"
        log_warn "  eval \"\$(/opt/homebrew/bin/brew shellenv)\""
        log_warn "After updating your profile, open a new shell or source the file so 'brew' is on PATH, then rerun setup."
        exit 2
    else
        fail "Homebrew installer failed"
    fi
}

install_bundle() {
    print_heading "Install Homebrew bundle"

    require_command brew

    # Always install the main Brewfile first
    main_manifest="${REPO_ROOT}/dotfiles/Brewfile"
    [[ -f "${main_manifest}" ]] || fail "Missing main Brewfile at ${main_manifest}"

    log_info "Installing common packages from main Brewfile"
    install_brewfile "${main_manifest}"

    # Install mode-specific packages if SETUP_MODE is set
    if [[ -n "${SETUP_MODE:-}" ]]; then
        mode_manifest="${REPO_ROOT}/dotfiles/Brewfile.${SETUP_MODE}"
        if [[ -f "${mode_manifest}" ]]; then
            log_info "Installing ${SETUP_MODE}-specific packages from ${mode_manifest}"
            install_brewfile "${mode_manifest}"
        else
            log_warn "No ${SETUP_MODE}-specific Brewfile found at ${mode_manifest}"
        fi
    else
        log_warn "SETUP_MODE not set, skipping mode-specific packages"
    fi
}

install_brewfile() {
    local manifest="$1"

    log_info "Running brew bundle install for ${manifest}"
    set +e
    brew bundle install --file="${manifest}"
    bundle_status=$?
    set -e

    if [[ ${bundle_status} -eq 0 ]]; then
        log_info "Brew bundle succeeded for ${manifest}"
        return 0
    fi

    log_warn "brew bundle reported errors for ${manifest}"

    log_warn "Running brew bundle check"
    if brew bundle check --file="${manifest}" >/dev/null 2>&1; then
        log_warn "brew bundle check reports all items installed for ${manifest}"
    else
        log_warn "brew bundle check indicates missing items for ${manifest}"
    fi
}

main() {
    case "${1:-}" in
        install)
            install_homebrew
            ;;
        bundle)
            install_bundle
            ;;
        help|--help|-h)
            show_help
            exit 0
            ;;
        "")
            install_homebrew
            install_bundle
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
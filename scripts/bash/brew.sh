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
    bundle      Install packages from Brewfile
    --help      Show this help message

If no command is specified, both install and bundle will be processed.
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

    manifest="${REPO_ROOT}/dotfiles/Brewfile"
    [[ -f "${manifest}" ]] || fail "Missing Brewfile at ${manifest}"

    log_info "Running brew bundle install"
    set +e
    brew bundle install --file="${manifest}"
    bundle_status=$?
    set -e

    if [[ ${bundle_status} -eq 0 ]]; then
        log_info "Brew bundle succeeded"
        return 0
    fi

    log_warn "brew bundle reported errors"

    log_warn "Running brew bundle check"
    if brew bundle check --file="${manifest}" >/dev/null 2>&1; then
        log_warn "brew bundle check reports all items installed"
    else
        fail "brew bundle check indicates missing items"
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
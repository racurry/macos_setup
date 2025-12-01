#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bash/common.sh
source "${SCRIPT_DIR}/../lib/bash/common.sh"

# Save original args to pass through to child scripts
ORIGINAL_ARGS=("$@")

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Automated macOS setup script that installs and configures development tools,
applications, and system settings.

OPTIONS:
  --unattended     Skip operations requiring human interaction
  --reset-mode     Ignore saved mode and prompt for selection
  --mode MODE      Set mode directly (work or personal)
  -h, --help       Show this help message and exit

CONFIGURATION:
  Configuration is persisted to ~/.config/motherbox/config

EXAMPLES:
  # First run
  ./run/setup.sh

  # Override saved mode, persist new mode
  ./run/setup.sh --mode work

  # Non-interactive setup (skip operations that need you, eg sudo)
  ./run/setup.sh --unattended

EOF
}

# Parse command line arguments (only handle --help, rest passed through)
for arg in "$@"; do
    case $arg in
        -h | --help)
            show_help
            exit 0
            ;;
    esac
done

# Determine setup mode (precedence: flag > config > prompt)
determine_setup_mode ${ORIGINAL_ARGS[@]+"${ORIGINAL_ARGS[@]}"} || exit 1

# Preflight checks
preflight_checks() {
    print_heading "System Requirements Check"
    log_info "Running preflight checks..."

    # Block running as root
    if [[ $EUID -eq 0 ]]; then
        fail "Run this setup as a regular user, not root"
    fi

    if [[ "$(pwd)" != "${REPO_ROOT}" ]]; then
        log_info "Changing working directory to ${REPO_ROOT}"
        cd "${REPO_ROOT}"
    fi

    log_info "Repository root resolved to ${REPO_ROOT}"
    log_info "Bash version ${BASH_VERSION}"

    # Xcode Command Line Tools check
    log_info "Checking Xcode Command Line Tools..."
    if xcode-select -p >/dev/null 2>&1; then
        log_info "Xcode Command Line Tools already installed"
    else
        log_info "Triggering Xcode Command Line Tools installation"
        if xcode-select --install; then
            log_info "Installer launched. Complete it, then rerun this script."
            exit 2
        else
            log_warn "Installer launch may have failed; verify manually and rerun."
            exit 1
        fi
    fi

    log_info "All system requirements checks passed"
}

# Run preflight checks before anything else
preflight_checks

# Run an app setup script, handling exit codes
# Passes ORIGINAL_ARGS to each script so they receive --mode, --unattended, etc.
run_app_setup() {
    local app="$1"
    local script="apps/${app}/${app}.sh"
    set +e
    (cd "${REPO_ROOT}" && bash "${script}" setup ${ORIGINAL_ARGS[@]+"${ORIGINAL_ARGS[@]}"})
    local status=$?
    set -e

    case ${status} in
        0) ;;
        2)
            log_warn "${app} requested manual follow-up; rerun once complete"
            exit 2
            ;;
        *)
            fail "${app} exited with status ${status}"
            ;;
    esac
}

print_heading "Baseline Required Apps"
run_app_setup brew

print_heading "Shell Settings"
run_app_setup zsh
run_app_setup ohmyzsh

print_heading "macOS Settings"
run_app_setup macos
run_app_setup icloud

print_heading "Dev Tools"
run_app_setup asdf
run_app_setup git
run_app_setup direnv
run_app_setup 1password
run_app_setup shellcheck
run_app_setup markdownlint
run_app_setup shfmt
run_app_setup ruff

print_heading "Application Settings"
run_app_setup claudecode

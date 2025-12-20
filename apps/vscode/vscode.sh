#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"

show_help() {
    cat <<EOF
Usage: $0 [COMMAND]

Visual Studio Code setup and backup.

VSCode installation and extensions are managed in apps/brew/Brewfile.
Preferences sync via VSCode's built-in Settings Sync (sign in with GitHub/Microsoft).

Commands:
    setup       Install VSCode and extensions via Homebrew
    backup      Backup settings, keybindings, snippets, and extensions list
    help        Show this help message (also: -h, --help)
EOF
}

do_setup() {
    print_heading "Setting up Visual Studio Code"

    # Install extensions from local Brewfile
    log_info "Installing VSCode extensions..."
    brew bundle --file="${SCRIPT_DIR}/Brewfile"

    log_info "Enable Settings Sync in VSCode to sync preferences across machines"
    log_success "VSCode setup complete"
}

# backup_directory copies a directory to the backup location.
# Similar to backup_file but handles directories with cp -r.
backup_directory() {
    local dir_path="$1"
    local app_name="$2"

    if [[ -z "$app_name" ]]; then
        fail "backup_directory requires app_name argument"
    fi

    if [[ ! -d "$dir_path" ]]; then
        log_info "Directory not found, skipping: $dir_path"
        return 0
    fi

    local dirname datestamp timestamp backup_dir backup_path
    dirname="$(basename "$dir_path")"
    datestamp="$(date +%Y%m%d)"
    timestamp="$(date +%Y%m%d_%H%M%S)"
    backup_dir="${PATH_MOTHERBOX_BACKUPS}/${datestamp}/${app_name}"
    backup_path="${backup_dir}/${dirname}.${timestamp}"

    mkdir -p "$backup_dir"
    cp -r "$dir_path" "$backup_path"
    log_warn "Backed up ${dirname}/ to ${backup_path}"
}

do_backup() {
    print_heading "Backing up Visual Studio Code"

    if [[ ! -d "${VSCODE_USER_DIR}" ]]; then
        fail "VSCode User directory not found: ${VSCODE_USER_DIR}"
    fi

    local datestamp timestamp backup_dir
    datestamp="$(date +%Y%m%d)"
    timestamp="$(date +%Y%m%d_%H%M%S)"
    backup_dir="${PATH_MOTHERBOX_BACKUPS}/${datestamp}/vscode"

    mkdir -p "${backup_dir}"

    # Backup settings.json
    local settings_file="${VSCODE_USER_DIR}/settings.json"
    if [[ -f "${settings_file}" ]]; then
        backup_file "${settings_file}" "vscode"
    else
        log_info "No settings.json found"
    fi

    # Backup keybindings.json
    local keybindings_file="${VSCODE_USER_DIR}/keybindings.json"
    if [[ -f "${keybindings_file}" ]]; then
        backup_file "${keybindings_file}" "vscode"
    else
        log_info "No keybindings.json found"
    fi

    # Backup snippets directory
    local snippets_dir="${VSCODE_USER_DIR}/snippets"
    if [[ -d "${snippets_dir}" ]]; then
        backup_directory "${snippets_dir}" "vscode"
    else
        log_info "No snippets directory found"
    fi

    # Export extensions list
    local extensions_file="${backup_dir}/extensions.${timestamp}.txt"
    if command -v code &>/dev/null; then
        log_info "Exporting installed extensions list..."
        code --list-extensions >"${extensions_file}"
        log_warn "Backed up extensions list to ${extensions_file}"
    else
        log_warn "VSCode 'code' command not available, skipping extensions export"
    fi

    log_success "VSCode backup complete: ${backup_dir}"
}

main() {
    local command=""
    local args=("$@")

    while [[ $# -gt 0 ]]; do
        case "$1" in
        help | --help | -h)
            show_help
            exit 0
            ;;
        setup | backup)
            command="$1"
            shift
            ;;
        *)
            # Check if it's a global flag from run/setup.sh
            if shift_count=$(check_global_flag "$@"); then
                shift "$shift_count"
            else
                log_warn "Ignoring unknown argument: $1"
                shift
            fi
            ;;
        esac
    done

    case "${command}" in
    setup)
        do_setup "${args[@]}"
        ;;
    backup)
        do_backup
        ;;
    "")
        show_help
        exit 0
        ;;
    esac
}

main "$@"

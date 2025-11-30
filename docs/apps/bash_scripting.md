# Bash Scripting

App scripts written in bash follow this template:

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

APP_NAME="appname"  # Used for backup organization

show_help() {
    cat << EOF
Usage: $0 [COMMAND] [OPTIONS]

Short description of what this script does.

Commands:
    setup       Run full setup (primary entry point)
    help        Show this help message (also: -h, --help)

Options:
    --flag      Description of the flag
EOF
}

do_setup() {
    print_heading "Setting up ${APP_NAME}"
    # Setup logic here
    log_info "Setup complete"
}

main() {
    local command=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --flag)
                # handle flag
                shift
                ;;
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
```

## Conventions

| Convention                            | Example                           |
| ------------------------------------- | --------------------------------- |
| Use `setup` as main entry point       | `./apps/myapp/myapp.sh setup`     |
| Accept `help`, `-h`, `--help`         | All three should work             |
| Use `fail` for errors                 | `fail "Missing config file"`      |
| Use `$REPO_ROOT` for paths            | `${REPO_ROOT}/apps/myapp/config`  |
| Use `--flag value` not `--flag=value` | `--mode work`                     |

## Available Functions (from `common.sh`)

| Function                            | Purpose                             |
| ----------------------------------- | ----------------------------------- |
| `print_heading "text"`              | Section headers                     |
| `log_info "text"`                   | Info messages                       |
| `log_warn "text"`                   | Warnings                            |
| `log_success "text"`                | Success messages                    |
| `fail "text"`                       | Error and exit                      |
| `require_command cmd`               | Guard: command exists               |
| `require_file path`                 | Guard: file exists                  |
| `require_directory path`            | Guard: directory exists             |
| `link_file src dest app_name`       | Symlink config (backs up existing)  |
| `copy_file src dest app_name`       | Copy config (backs up existing)     |

See [copying_configs.md](copying_configs.md) for details on `link_file` vs `copy_file`.

## Path Variables (from `common.sh`)

| Variable                     | Value                         |
| ---------------------------- | ----------------------------- |
| `$REPO_ROOT`                 | Repository root path          |
| `$PATH_MOTHERBOX_CONFIG`     | `~/.config/motherbox`         |
| `$PATH_MOTHERBOX_CONFIG_FILE`| `~/.config/motherbox/config`  |
| `$PATH_MOTHERBOX_BACKUPS`    | `~/.config/motherbox/backups` |

## Related Documentation

- [copying_configs.md](copying_configs.md) - `link_file` and `copy_file` usage
- [config_backups.md](config_backups.md) - `backup_file` and retention policy
- [motherbox_configs.md](../motherbox_configs.md) - `get_config` and `set_config`

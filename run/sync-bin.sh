#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bash/common.sh
source "${SCRIPT_DIR}/../lib/bash/common.sh"

# Create ~/.config/motherbox/bin symlink to repo bin
# This provides a stable path for PATH that survives repo moves/renames

config_dir="$HOME/.config/motherbox"
bin_link="$config_dir/bin"
target="${REPO_ROOT}/bin"

mkdir -p "$config_dir"

if [[ -L "$bin_link" ]]; then
    current_target="$(readlink "$bin_link")"
    if [[ "$current_target" == "$target" ]]; then
        log_info "Bin symlink already correct: $bin_link"
        exit 0
    fi
    rm "$bin_link"
elif [[ -e "$bin_link" ]]; then
    fail "$bin_link exists but is not a symlink"
fi

ln -s "$target" "$bin_link"
log_success "Created symlink: $bin_link → $target"

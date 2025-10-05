#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Create a symbolic link from ~/iCloud to the iCloud Drive directory.

OPTIONS:
  -h, --help    Show this help message and exit

DESCRIPTION:
  This script creates a convenient symlink from ~/iCloud to the actual iCloud
  Drive directory at ~/Library/Mobile Documents/com~apple~CloudDocs. If iCloud
  Drive is not available, the script will skip the operation. If a symlink
  already exists and points to the correct location, it will be left unchanged.
  If an existing symlink points elsewhere, it will be updated.

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      show_help
      exit 1
      ;;
  esac
done

print_heading "Set iCloud symlink"

TARGET_LINK="${SETUP_PATH_ICLOUD}"
ICLOUD_SOURCE="${SETUP_PATH_ICLOUD_MOBILE_DOCUMENTS}"

if [[ ! -d "${ICLOUD_SOURCE}" ]]; then
  log_warn "iCloud Drive not found at ${ICLOUD_SOURCE}; skipping symlink"
  exit 0
fi

if [[ -L "${TARGET_LINK}" ]]; then
  current_target="$(readlink "${TARGET_LINK}")"
  if [[ "${current_target}" == "${ICLOUD_SOURCE}" ]]; then
    log_info "'~/iCloud' is already correctly symlinked"
    exit 0
  else
    log_info "Updating existing symlink from ${current_target} to ${ICLOUD_SOURCE}"
    ln -sf "${ICLOUD_SOURCE}" "${TARGET_LINK}"
    exit 0
  fi
fi

if [[ -e "${TARGET_LINK}" ]]; then
  fail "${TARGET_LINK} exists and is not a symlink"
fi

log_info "Creating iCloud symlink ${TARGET_LINK} -> ${ICLOUD_SOURCE}"
ln -s "${ICLOUD_SOURCE}" "${TARGET_LINK}"
log_info "'~/iCloud' is correctly symlinked"

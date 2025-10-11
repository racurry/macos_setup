#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
  cat << EOF
Usage: $(basename "$0") [PARENT_DIR]

Create organizational folder structure in the specified parent directory.

Arguments:
  PARENT_DIR    Parent directory for folders (default: ~/Documents)

Folders created:
  - @auto (automated/scripted content)
  - 000_Inbox (incoming items to be processed)
  - 100_Life (personal life organization)
  - 150_Projects (active projects)
  - 200_People (people-related information)
  - 400_Topics (topic-based resources)
  - 700_Libraries (reference materials)
  - 800_Posterity (long-term archival)
  - 999_Meta (meta information about the system)

Options:
  -h, --help    Show this help message

Examples:
  $(basename "$0")                           # Create in ~/Documents (default)
  $(basename "$0") ~/iCloud/Documents        # Create in iCloud
  $(basename "$0") "/path/to/DevonThink"    # Create in DevonThink

EOF
}

# Parse arguments
case ${1:-} in
  -h|--help)
    show_help
    exit 0
    ;;
esac


# Set parent directory (default to ~/Documents)
DOCS_DIR="${1:-${PATH_DOCUMENTS}}"

print_heading "Make folders how I like em"

log_info "Parent directory: ${DOCS_DIR}"

# Ensure parent directory exists
if [[ ! -d "${DOCS_DIR}" ]]; then
  log_error "Parent directory does not exist: ${DOCS_DIR}"
  exit 1
fi

folders=(
  "@auto"
  "000_Inbox"
  "100_Life"
  "150_Projects"
  "200_People"
  "400_Topics"
  "700_Libraries"
  "800_Posterity"
  "999_Meta"
)

for folder in "${folders[@]}"; do
  target="${DOCS_DIR}/${folder}"
  if [[ -d "${target}" ]]; then
    log_info "Folder already exists: ${target}"
  else
    log_info "Creating folder: ${target}"
    mkdir -p "${target}"
  fi
done

log_info "Created the folders we like"

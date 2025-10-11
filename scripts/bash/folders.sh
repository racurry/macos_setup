#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Create a standard set of organizational folders in the Documents directory.

OPTIONS:
  -h, --help    Show this help message and exit

DESCRIPTION:
  This script creates a predefined set of folders in ~/Documents for organizing
  documents and projects. The folders created include:

  - @auto (automated/scripted content)
  - 000_Inbox (incoming items to be processed)
  - 100_Life (personal life organization)
  - 150_Projects (active projects)
  - 200_People (people-related information)
  - 400_Topics (topic-based resources)
  - 700_Libraries (reference materials)
  - 800_Posterity (long-term archival)
  - 999_Meta (meta information about the system)

  If a folder already exists, it will be left unchanged.

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

print_heading "Make folders how I like em"

DOCS_DIR="${PATH_DOCUMENTS}"

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

log_info "Checking the docs dir ${DOCS_DIR}"
mkdir -p "${DOCS_DIR}"

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

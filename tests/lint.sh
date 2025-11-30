#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Run shellcheck linting on all bash scripts in the repository.

OPTIONS:
  -h, --help    Show this help message and exit

DESCRIPTION:
  This script finds all .sh files in lib/bash, scripts, and apps directories
  and runs shellcheck on them to verify bash syntax and best practices.

PREREQUISITES:
  - shellcheck (install with: brew install shellcheck)

EXIT CODES:
  0 - All scripts passed shellcheck
  1 - One or more scripts failed shellcheck or shellcheck not found

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

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "shellcheck not found; install with 'brew install shellcheck'" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

bash_sources=()
while IFS= read -r file; do
  bash_sources+=("$file")
done < <(find "${REPO_ROOT}/lib/bash" "${REPO_ROOT}/scripts" "${REPO_ROOT}/apps" -name '*.sh' -print | sort)

if [ ${#bash_sources[@]} -eq 0 ]; then
  echo "No bash sources found" >&2
  exit 0
fi

echo "Running shellcheck on ${#bash_sources[@]} bash files..."
shellcheck --source-path="${REPO_ROOT}" "${bash_sources[@]}"
echo "✓ All bash files passed shellcheck"

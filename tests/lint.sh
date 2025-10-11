#!/usr/bin/env bash
# Linting script for bash and Python files in the repository.
#
# Usage:
#   ./tests/lint.sh
#   ./tests/lint.sh --help
#
# Files linted:
#   - Bash: lib/bash/, scripts/bash/, tests/*.sh
#   - Python: scripts/python/, tests/*.py
#
# Prerequisites:
#   - shellcheck (brew install shellcheck)
#   - flake8 (pip install flake8)

set -euo pipefail

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Run shellcheck linting on all bash scripts in the repository.

OPTIONS:
  -h, --help    Show this help message and exit

DESCRIPTION:
  This script finds all .sh files in lib/bash and scripts/bash directories
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

# Source common functions
# shellcheck source=../lib/bash/common.sh
source "${REPO_ROOT}/lib/bash/common.sh"

# Override LOG_TAG for this script
LOG_TAG="lint"

show_help() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Linting script for bash and Python files in the repository.

Options:
  -h, --help    Show this help message and exit

Files linted:
  - Bash: lib/bash/, scripts/bash/, tests/*.sh
  - Python: scripts/python/, tests/*.py

Prerequisites:
  - shellcheck (brew install shellcheck)
  - flake8 (pip install flake8)

Examples:
  ./tests/lint.sh

EOF
  exit 0
}

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    -h|--help)
      show_help
      ;;
    *)
      log_error "Unknown argument: $arg"
      echo "Use --help for usage information" >&2
      exit 1
      ;;
  esac
done

print_heading "Running Linters"

# ============================================================================
# Bash linting with shellcheck
# ============================================================================
log_info "Linting bash files..."

if ! command -v shellcheck >/dev/null 2>&1; then
  fail "shellcheck not found; install with 'brew install shellcheck'"
fi

bash_sources=()
while IFS= read -r file; do
  bash_sources+=("$file")
done < <(find "${REPO_ROOT}/lib/bash" "${REPO_ROOT}/scripts/bash" "${REPO_ROOT}/tests" -name '*.sh' -print | sort)

if [ ${#bash_sources[@]} -eq 0 ]; then
  log_warn "No bash files found to lint"
else
  shellcheck "${bash_sources[@]}"
  log_info "✓ Bash files passed shellcheck (${#bash_sources[@]} files)"
fi

# ============================================================================
# Python linting with flake8
# ============================================================================
log_info "Linting Python files..."

if ! command -v flake8 >/dev/null 2>&1; then
  fail "flake8 not found; install with 'pip install flake8'"
fi

python_sources=()
while IFS= read -r file; do
  python_sources+=("$file")
done < <(find "${REPO_ROOT}/scripts/python" "${REPO_ROOT}/tests" -name '*.py' -print 2>/dev/null | sort)

if [ ${#python_sources[@]} -eq 0 ]; then
  log_warn "No Python files found to lint"
else
  flake8 "${python_sources[@]}"
  log_info "✓ Python files passed flake8 (${#python_sources[@]} files)"
fi

# ============================================================================
# Summary
# ============================================================================
print_heading "All linting checks passed!"

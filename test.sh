#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_help() {
  cat << EOF
Usage: $(basename "$0") [COMMAND] [OPTIONS]

Run tests for the macOS setup repository.

COMMANDS:
  lint      Run shellcheck linting on all bash scripts
  unit      Run bats unit tests
  all       Run both lint and unit tests (default)

OPTIONS:
  -h, --help    Show this help message and exit

PREREQUISITES:
  - shellcheck (install with: brew install shellcheck)
  - bats-core (install with: brew install bats-core)

EXIT CODES:
  0 - All tests passed
  1 - One or more tests failed

EXAMPLES:
  $(basename "$0")           # Run all tests (lint + unit)
  $(basename "$0") lint      # Run only shellcheck
  $(basename "$0") unit      # Run only unit tests
  $(basename "$0") all       # Run all tests (explicit)

EOF
}

run_lint() {
  if ! command -v shellcheck >/dev/null 2>&1; then
    echo "shellcheck not found; install with 'brew install shellcheck'" >&2
    return 1
  fi

  echo "Running shellcheck linting..."

  bash_sources=()
  while IFS= read -r file; do
    bash_sources+=("$file")
  done < <(find "${SCRIPT_DIR}/lib/bash" "${SCRIPT_DIR}/scripts" "${SCRIPT_DIR}/apps" -name '*.sh' -print | sort)

  if [ ${#bash_sources[@]} -eq 0 ]; then
    echo "No bash sources found" >&2
    return 0
  fi

  echo "Checking ${#bash_sources[@]} bash files..."
  shellcheck --source-path="${SCRIPT_DIR}" "${bash_sources[@]}"
  echo "✓ All bash files passed shellcheck"
}

run_unit() {
  if ! command -v bats >/dev/null 2>&1; then
    echo "bats not found; install with 'brew install bats-core'" >&2
    return 1
  fi

  echo "Running unit tests..."

  # Discover all test files in apps/, scripts/, and lib/
  bats "${SCRIPT_DIR}"/apps/*/test_*.bats \
       "${SCRIPT_DIR}"/scripts/test_*.bats \
       "${SCRIPT_DIR}"/lib/test_*.bats
}

# Parse command
COMMAND="${1:-all}"

case "$COMMAND" in
  -h|--help)
    show_help
    exit 0
    ;;
  lint)
    run_lint
    ;;
  unit)
    run_unit
    ;;
  all)
    run_lint
    echo ""
    run_unit
    echo ""
    echo "All tests completed successfully!"
    ;;
  *)
    echo "Unknown command: $COMMAND" >&2
    show_help
    exit 1
    ;;
esac

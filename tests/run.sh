#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Run all tests for the macOS setup repository.

OPTIONS:
  -h, --help    Show this help message and exit

TESTS RUN:
  1. Lint tests (shellcheck on all bash scripts)
  2. Unit tests (bats test suite)

PREREQUISITES:
  - shellcheck (install with: brew install shellcheck)
  - bats-core (install with: brew install bats-core)

EXIT CODES:
  0 - All tests passed
  1 - One or more tests failed

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

echo "Running lint tests..."
"${SCRIPT_DIR}/lint.sh"

echo "Running unit tests..."
"${SCRIPT_DIR}/unit.sh"

echo "All tests completed successfully!"
#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Run unit tests using the bats testing framework.

OPTIONS:
  -h, --help    Show this help message and exit

DESCRIPTION:
  This script runs all bats test files located in the tests/unit directory.

PREREQUISITES:
  - bats-core (install with: brew install bats-core)

EXIT CODES:
  0 - All tests passed
  1 - One or more tests failed or bats not found

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

if ! command -v bats >/dev/null 2>&1; then
  echo "bats not found; install with 'brew install bats-core'" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bats "${SCRIPT_DIR}/unit"

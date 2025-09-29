#!/usr/bin/env bash
set -euo pipefail

if ! command -v bats >/dev/null 2>&1; then
  echo "bats not found; install with 'brew install bats-core'" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bats "${SCRIPT_DIR}/unit"

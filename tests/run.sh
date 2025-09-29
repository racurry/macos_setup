#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Running lint tests..."
"${SCRIPT_DIR}/lint.sh"

echo "Running unit tests..."
"${SCRIPT_DIR}/unit.sh"

echo "All tests completed successfully!"
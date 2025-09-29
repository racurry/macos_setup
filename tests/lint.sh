#!/usr/bin/env bash
set -euo pipefail

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "shellcheck not found; install with 'brew install shellcheck'" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

bash_sources=()
while IFS= read -r file; do
  bash_sources+=("$file")
done < <(find "${REPO_ROOT}/lib/bash" "${REPO_ROOT}/scripts/bash" -name '*.sh' -print | sort)

if [ ${#bash_sources[@]} -eq 0 ]; then
  echo "No bash sources found" >&2
  exit 0
fi

shellcheck "${bash_sources[@]}"

#!/usr/bin/env bash
# Shared setup for BATS unit tests targeting lib/bash/common.sh utilities.

TEST_HELPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${TEST_HELPER_DIR}/../.." && pwd)"

# Allow ShellCheck to resolve this relative source path.
# shellcheck source=lib/bash/common.sh
source "${REPO_ROOT}/lib/bash/common.sh"

# Use a deterministic log tag for test output assertions.
LOG_TAG="test"

# Override fail() so library functions return a non-zero status instead of
# terminating the entire BATS process. The message is still emitted on stderr
# for assertions.
fail() {
  log_error "$@"
  return 1
}

# Helper function to create a minimal PATH with essential commands
create_minimal_path() {
  local tmpdir="$1"
  local exclude_cmd="$2"

  mkdir -p "${tmpdir}/bin"

  # Essential commands needed by most scripts
  local commands=(
    "bash" "sh" "rm" "mkdir" "pwd" "dirname" "basename"
    "cat" "echo" "test" "true" "false" "sleep" "grep"
    "awk" "sed" "sort" "uniq" "head" "tail" "ln"
    "printf" "command" "type" "which" "env"
  )

  for cmd in "${commands[@]}"; do
    if [[ "$cmd" != "$exclude_cmd" ]]; then
      local cmd_path
      if cmd_path=$(command -v "$cmd" 2>/dev/null) && [[ -x "$cmd_path" ]]; then
        ln -sf "$cmd_path" "${tmpdir}/bin/$cmd"
      fi
    fi
  done
}

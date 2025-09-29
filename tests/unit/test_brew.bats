#!/usr/bin/env bats

load '../helpers/common_test_helper.bash'

setup() {
  TEST_TMPDIR="$(mktemp -d)"
}

teardown() {
  rm -rf "${TEST_TMPDIR}"
}

@test "brew.sh install succeeds when brew is available in PATH" {
  # Skip this test if we don't have curl
  if ! command -v curl >/dev/null 2>&1; then
    skip "curl command not available"
  fi

  # Create mock brew command that reports it's already installed
  mkdir -p "${TEST_TMPDIR}/bin"
  ln -s "$(command -v true)" "${TEST_TMPDIR}/bin/brew"
  export PATH="${TEST_TMPDIR}/bin:${PATH}"

  run bash "${REPO_ROOT}/scripts/bash/brew.sh" install
  [ "$status" -eq 0 ]
  [[ "$output" == *"Homebrew already installed"* ]]
}

@test "brew.sh shows help when --help is passed" {
  run bash "${REPO_ROOT}/scripts/bash/brew.sh" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"install"* ]]
  [[ "$output" == *"bundle"* ]]
}

@test "brew.sh shows error for unknown command" {
  run bash "${REPO_ROOT}/scripts/bash/brew.sh" unknown
  [ "$status" -eq 1 ]
  [[ "$output" == *"Error: Unknown command"* ]]
}

@test "brew.sh bundle requires brew command" {
  # Remove brew from PATH if it exists
  export PATH="$(echo "$PATH" | tr ':' '\n' | grep -v brew | tr '\n' ':')"

  run bash "${REPO_ROOT}/scripts/bash/brew.sh" bundle
  [ "$status" -ne 0 ]
}
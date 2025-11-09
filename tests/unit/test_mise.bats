#!/usr/bin/env bats

load '../helpers/common_test_helper.bash'

setup() {
  TEST_TMPDIR="$(mktemp -d)"
  TEST_HOME="${TEST_TMPDIR}/home"
  TEST_REPO_ROOT="${TEST_TMPDIR}/repo"
  TEST_DOTFILES="${TEST_REPO_ROOT}/dotfiles"

  mkdir -p "${TEST_HOME}"
  mkdir -p "${TEST_DOTFILES}"

  ORIGINAL_HOME="${HOME:-}"
  ORIGINAL_REPO_ROOT="${REPO_ROOT:-}"
  export HOME="${TEST_HOME}"
  export REPO_ROOT="${TEST_REPO_ROOT}"

  SCRIPT_PATH="${BATS_TEST_DIRNAME}/../../scripts/bash/mise.sh"
}

teardown() {
  rm -rf "${TEST_TMPDIR}"
  if [[ -n "${ORIGINAL_HOME}" ]]; then
    export HOME="${ORIGINAL_HOME}"
  else
    unset HOME
  fi
  if [[ -n "${ORIGINAL_REPO_ROOT}" ]]; then
    export REPO_ROOT="${ORIGINAL_REPO_ROOT}"
  else
    unset REPO_ROOT
  fi
}

@test "mise runtimes fails when mise not installed" {
  # Create a minimal PATH excluding mise
  create_minimal_path "${TEST_TMPDIR}" "mise"

  run env PATH="${TEST_TMPDIR}/bin" HOME="${HOME}" REPO_ROOT="${REPO_ROOT}" bash "${SCRIPT_PATH}" runtimes
  [ "$status" -eq 1 ]
  [[ "$output" == *"Required command 'mise' not found in PATH"* ]]
}

@test "mise install fails when mise not installed" {
  # Create a minimal PATH excluding mise
  create_minimal_path "${TEST_TMPDIR}" "mise"

  run env PATH="${TEST_TMPDIR}/bin" HOME="${HOME}" REPO_ROOT="${REPO_ROOT}" bash "${SCRIPT_PATH}" install
  [ "$status" -eq 1 ]
  [[ "$output" == *"Required command 'mise' not found in PATH"* ]]
}

@test "mise shows help with no arguments" {
  run bash "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"install"* ]]
  [[ "$output" == *"runtimes"* ]]
}

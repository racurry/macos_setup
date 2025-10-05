#!/usr/bin/env bats

load '../helpers/common_test_helper.bash'

setup() {
  ORIGINAL_PWD="$(pwd)"
}

teardown() {
  cd "$ORIGINAL_PWD"
}

@test "script exists and is executable" {
  [ -f "${REPO_ROOT}/scripts/bash/mvp_system_reqs_check.sh" ]
  [ -x "${REPO_ROOT}/scripts/bash/mvp_system_reqs_check.sh" ]
}

@test "script outputs system requirements check heading" {
  run bash "${REPO_ROOT}/scripts/bash/mvp_system_reqs_check.sh"
  [[ "$output" == *"System Requirements Check (MVP)"* ]]
}

@test "script runs successfully from repo root" {
  cd "${REPO_ROOT}"
  run bash "${REPO_ROOT}/scripts/bash/mvp_system_reqs_check.sh"
  # Should succeed (exit 0) or indicate missing tools (exit 1) but not crash
  [[ "$status" -eq 0 || "$status" -eq 1 || "$status" -eq 2 ]]
}

@test "script changes to repo root when run from elsewhere" {
  # Create a temp directory and run from there
  TEST_TMPDIR="$(mktemp -d)"
  cd "${TEST_TMPDIR}"

  run bash "${REPO_ROOT}/scripts/bash/mvp_system_reqs_check.sh"
  [[ "$output" == *"Changing working directory to ${REPO_ROOT}"* ]]

  rm -rf "${TEST_TMPDIR}"
}

@test "script requires essential commands" {
  run bash "${REPO_ROOT}/scripts/bash/mvp_system_reqs_check.sh"
  # If any required commands are missing, script should fail with helpful message
  if [[ "$status" -eq 1 ]]; then
    [[ "$output" == *"Required command"* && "$output" == *"not found"* ]]
  fi
}

@test "help flag displays usage information" {
  run bash "${REPO_ROOT}/scripts/bash/mvp_system_reqs_check.sh" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage:" ]]
  [[ "$output" =~ "--skip-sudo" ]]
}

@test "--skip-sudo flag is accepted" {
  cd "${REPO_ROOT}"
  run bash "${REPO_ROOT}/scripts/bash/mvp_system_reqs_check.sh" --skip-sudo
  # Should not fail with "unknown option" error
  [[ ! "$output" =~ "Error: Unknown option" ]]
}

@test "--skip-sudo skips sudo check" {
  cd "${REPO_ROOT}"
  run bash "${REPO_ROOT}/scripts/bash/mvp_system_reqs_check.sh" --skip-sudo
  [[ "$output" =~ "Skipping sudo availability check" ]]
}
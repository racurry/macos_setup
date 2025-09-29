#!/usr/bin/env bats

setup() {
  TEST_TMPDIR="$(mktemp -d)"
  ORIGINAL_HOME="${HOME:-}"
  export HOME="${TEST_TMPDIR}/home"
  mkdir -p "${HOME}"
  SCRIPT_PATH="${BATS_TEST_DIRNAME}/../../scripts/bash/folders.sh"
}

teardown() {
  rm -rf "${TEST_TMPDIR}"
  if [[ -n "${ORIGINAL_HOME}" ]]; then
    export HOME="${ORIGINAL_HOME}"
  else
    unset HOME
  fi
}

@test "create_documents_tree creates expected folders" {
  run env HOME="${HOME}" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
  for folder in "@auto" 000_Inbox 100_Life 150_Projects 200_People 400_Topics 700_Libraries 800_Posterity 999_Meta; do
    [ -d "${HOME}/Documents/${folder}" ]
  done
}

@test "create_documents_tree is idempotent" {
  env HOME="${HOME}" "${SCRIPT_PATH}"
  run env HOME="${HOME}" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "folders.sh --help shows usage information" {
  run "${SCRIPT_PATH}" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"Create a standard set of organizational folders"* ]]
  [[ "$output" == *"-h, --help"* ]]
}

@test "folders.sh -h shows usage information" {
  run "${SCRIPT_PATH}" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"Create a standard set of organizational folders"* ]]
  [[ "$output" == *"-h, --help"* ]]
}

@test "folders.sh with unknown option shows error and help" {
  run "${SCRIPT_PATH}" --invalid-option
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option: --invalid-option"* ]]
  [[ "$output" == *"Usage:"* ]]
}

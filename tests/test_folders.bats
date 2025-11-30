#!/usr/bin/env bats

setup() {
  TEST_TMPDIR="$(mktemp -d)"
  ORIGINAL_HOME="${HOME:-}"
  export HOME="${TEST_TMPDIR}/home"
  mkdir -p "${HOME}"
  SCRIPT_PATH="${BATS_TEST_DIRNAME}/../apps/macos/folders.sh"
}

teardown() {
  rm -rf "${TEST_TMPDIR}"
  if [[ -n "${ORIGINAL_HOME}" ]]; then
    export HOME="${ORIGINAL_HOME}"
  else
    unset HOME
  fi
}

@test "create_documents_tree creates expected folders in default location" {
  run env HOME="${HOME}" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
  for folder in "@auto" 000_Inbox 100_Life 150_Projects 200_People 400_Topics 700_Libraries 800_Posterity 999_Meta; do
    [ -d "${HOME}/Documents/${folder}" ]
  done
}

@test "create_documents_tree creates expected folders in custom location" {
  mkdir -p "${TEST_TMPDIR}/custom_dir"
  run env HOME="${HOME}" "${SCRIPT_PATH}" "${TEST_TMPDIR}/custom_dir"
  [ "$status" -eq 0 ]
  for folder in "@auto" 000_Inbox 100_Life 150_Projects 200_People 400_Topics 700_Libraries 800_Posterity 999_Meta; do
    [ -d "${TEST_TMPDIR}/custom_dir/${folder}" ]
  done
}

@test "create_documents_tree expands tilde in path" {
  run env HOME="${HOME}" "${SCRIPT_PATH}" "~/Documents"
  [ "$status" -eq 0 ]
  for folder in "@auto" 000_Inbox 100_Life 150_Projects 200_People 400_Topics 700_Libraries 800_Posterity 999_Meta; do
    [ -d "${HOME}/Documents/${folder}" ]
  done
}

@test "create_documents_tree fails if parent directory doesn't exist" {
  run env HOME="${HOME}" "${SCRIPT_PATH}" "${TEST_TMPDIR}/nonexistent"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Parent directory does not exist"* ]]
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
  [[ "$output" == *"Create organizational folder structure"* ]]
  [[ "$output" == *"-h, --help"* ]]
}

@test "folders.sh -h shows usage information" {
  run "${SCRIPT_PATH}" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"Create organizational folder structure"* ]]
  [[ "$output" == *"-h, --help"* ]]
}

@test "folders.sh with unknown option shows error and help" {
  run "${SCRIPT_PATH}" --invalid-option
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option: --invalid-option"* ]]
  [[ "$output" == *"Usage:"* ]]
}

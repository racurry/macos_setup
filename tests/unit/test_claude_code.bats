#!/usr/bin/env bats

load '../helpers/common_test_helper.bash'

setup() {
  TEST_TMPDIR="$(mktemp -d)"
  ORIGINAL_HOME="${HOME:-}"
  export HOME="${TEST_TMPDIR}/home"
  mkdir -p "${HOME}"
  CLAUDE_CODE_SCRIPT="${REPO_ROOT}/scripts/bash/claude_code.sh"
  CLAUDE_DIR="${HOME}/.claude"
  DEST="${CLAUDE_DIR}/CLAUDE.md"
  SRC="${REPO_ROOT}/apps/claude_code/CLAUDE.md"
}

teardown() {
  rm -rf "${TEST_TMPDIR}"
  if [[ -n "${ORIGINAL_HOME}" ]]; then
    export HOME="${ORIGINAL_HOME}"
  else
    unset HOME
  fi
}

@test "claude_code.sh creates symlink when none exists" {
  run env HOME="${HOME}" "${CLAUDE_CODE_SCRIPT}"
  [ "$status" -eq 0 ]
  [ -L "${DEST}" ]
  [[ "$(readlink "${DEST}")" == "${SRC}" ]]
}

@test "claude_code.sh leaves existing symlink pointing correctly" {
  mkdir -p "${CLAUDE_DIR}"
  ln -s "${SRC}" "${DEST}"
  run env HOME="${HOME}" "${CLAUDE_CODE_SCRIPT}"
  [ "$status" -eq 0 ]
  [ -L "${DEST}" ]
  [[ "$(readlink "${DEST}")" == "${SRC}" ]]
  [[ "$output" == *"Symlink already correct"* ]]
}

@test "claude_code.sh replaces incorrect symlink" {
  mkdir -p "${CLAUDE_DIR}"
  ln -s "/tmp/wrong_target" "${DEST}"
  run env HOME="${HOME}" "${CLAUDE_CODE_SCRIPT}"
  [ "$status" -eq 0 ]
  [ -L "${DEST}" ]
  [[ "$(readlink "${DEST}")" == "${SRC}" ]]
  [[ "$output" == *"Removing existing symlink"* ]]
}

@test "claude_code.sh replaces existing file" {
  mkdir -p "${CLAUDE_DIR}"
  echo "old content" > "${DEST}"
  run env HOME="${HOME}" "${CLAUDE_CODE_SCRIPT}"
  [ "$status" -eq 0 ]
  [ -L "${DEST}" ]
  [[ "$(readlink "${DEST}")" == "${SRC}" ]]
  [[ "$output" == *"Removing existing file"* ]]
}

@test "claude_code.sh --help shows usage information" {
  run "${CLAUDE_CODE_SCRIPT}" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"Create a symlink to the Claude Code configuration file"* ]]
  [[ "$output" == *"-h, --help"* ]]
}

@test "claude_code.sh -h shows usage information" {
  run "${CLAUDE_CODE_SCRIPT}" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"Create a symlink to the Claude Code configuration file"* ]]
  [[ "$output" == *"-h, --help"* ]]
}

@test "claude_code.sh with unknown option shows error and help" {
  run "${CLAUDE_CODE_SCRIPT}" --invalid-option
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option: --invalid-option"* ]]
  [[ "$output" == *"Usage:"* ]]
}

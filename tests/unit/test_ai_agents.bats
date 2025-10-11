#!/usr/bin/env bats

load '../helpers/common_test_helper.bash'

setup() {
  TEST_TMPDIR="$(mktemp -d)"
  ORIGINAL_HOME="${HOME:-}"
  export HOME="${TEST_TMPDIR}/home"
  mkdir -p "${HOME}"
  AI_AGENTS_SCRIPT="${REPO_ROOT}/scripts/bash/ai_agents.sh"
  AI_AGENTS_DIR="${HOME}/.ai_agents"
  DEST="${AI_AGENTS_DIR}/AGENTS.md"
  SRC="${REPO_ROOT}/apps/ai_coding/AGENTS.md"
}

teardown() {
  rm -rf "${TEST_TMPDIR}"
  if [[ -n "${ORIGINAL_HOME}" ]]; then
    export HOME="${ORIGINAL_HOME}"
  else
    unset HOME
  fi
}

@test "ai_agents.sh creates symlink when none exists" {
  run env HOME="${HOME}" "${AI_AGENTS_SCRIPT}"
  [ "$status" -eq 0 ]
  [ -L "${DEST}" ]
  [[ "$(readlink "${DEST}")" == "${SRC}" ]]
}

@test "ai_agents.sh leaves existing symlink pointing correctly" {
  mkdir -p "${AI_AGENTS_DIR}"
  ln -s "${SRC}" "${DEST}"
  run env HOME="${HOME}" "${AI_AGENTS_SCRIPT}"
  [ "$status" -eq 0 ]
  [ -L "${DEST}" ]
  [[ "$(readlink "${DEST}")" == "${SRC}" ]]
  [[ "$output" == *"Symlink already correct"* ]]
}

@test "ai_agents.sh replaces incorrect symlink" {
  mkdir -p "${AI_AGENTS_DIR}"
  ln -s "/tmp/wrong_target" "${DEST}"
  run env HOME="${HOME}" "${AI_AGENTS_SCRIPT}"
  [ "$status" -eq 0 ]
  [ -L "${DEST}" ]
  [[ "$(readlink "${DEST}")" == "${SRC}" ]]
  [[ "$output" == *"Removing existing symlink"* ]]
}

@test "ai_agents.sh replaces existing file" {
  mkdir -p "${AI_AGENTS_DIR}"
  echo "old content" > "${DEST}"
  run env HOME="${HOME}" "${AI_AGENTS_SCRIPT}"
  [ "$status" -eq 0 ]
  [ -L "${DEST}" ]
  [[ "$(readlink "${DEST}")" == "${SRC}" ]]
  [[ "$output" == *"Removing existing file"* ]]
}

@test "ai_agents.sh --help shows usage information" {
  run "${AI_AGENTS_SCRIPT}" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"Create a symlink to the AI coding agents configuration file"* ]]
  [[ "$output" == *"-h, --help"* ]]
}

@test "ai_agents.sh -h shows usage information" {
  run "${AI_AGENTS_SCRIPT}" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"Create a symlink to the AI coding agents configuration file"* ]]
  [[ "$output" == *"-h, --help"* ]]
}

@test "ai_agents.sh with unknown option shows error and help" {
  run "${AI_AGENTS_SCRIPT}" --invalid-option
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option: --invalid-option"* ]]
  [[ "$output" == *"Usage:"* ]]
}

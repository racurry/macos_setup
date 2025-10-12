#!/usr/bin/env bats

load '../helpers/common_test_helper.bash'

setup() {
  TEST_TMPDIR="$(mktemp -d)"
  ORIGINAL_HOME="${HOME:-}"
  export HOME="${TEST_TMPDIR}/home"
  mkdir -p "${HOME}"

  CLAUDECODE_SCRIPT="${REPO_ROOT}/scripts/bash/claudecode.sh"
}

teardown() {
  rm -rf "${TEST_TMPDIR}"
  if [[ -n "${ORIGINAL_HOME}" ]]; then
    export HOME="${ORIGINAL_HOME}"
  else
    unset HOME
  fi
}

@test "claudecode.sh creates hooks symlinks" {
  run env HOME="${HOME}" "${CLAUDECODE_SCRIPT}"
  [ "$status" -eq 0 ]
  [ -L "${HOME}/.claude/hooks/lint-and-fix.sh" ]
  [ "$(readlink "${HOME}/.claude/hooks/lint-and-fix.sh")" = "${REPO_ROOT}/apps/claudecode/hooks/lint-and-fix.sh" ]
}

@test "claudecode.sh creates commands symlinks recursively" {
  run env HOME="${HOME}" "${CLAUDECODE_SCRIPT}"
  [ "$status" -eq 0 ]
  [ -L "${HOME}/.claude/commands/git/commit.md" ]
  [ "$(readlink "${HOME}/.claude/commands/git/commit.md")" = "${REPO_ROOT}/apps/claudecode/commands/git/commit.md" ]
}

@test "claudecode.sh creates AGENTS.md symlink as CLAUDE.md" {
  run env HOME="${HOME}" "${CLAUDECODE_SCRIPT}"
  [ "$status" -eq 0 ]
  [ -L "${HOME}/.claude/CLAUDE.md" ]
  [ "$(readlink "${HOME}/.claude/CLAUDE.md")" = "${REPO_ROOT}/AGENTS.md" ]
}

@test "claudecode.sh is idempotent" {
  env HOME="${HOME}" "${CLAUDECODE_SCRIPT}"
  run env HOME="${HOME}" "${CLAUDECODE_SCRIPT}"
  [ "$status" -eq 0 ]
  [ -L "${HOME}/.claude/hooks/lint-and-fix.sh" ]
  [ -L "${HOME}/.claude/commands/git/commit.md" ]
  [ -L "${HOME}/.claude/CLAUDE.md" ]
}

@test "claudecode.sh backs up existing CLAUDE.md file to CLAUDE.local.md" {
  mkdir -p "${HOME}/.claude"
  echo "existing content" > "${HOME}/.claude/CLAUDE.md"

  run env HOME="${HOME}" "${CLAUDECODE_SCRIPT}"
  [ "$status" -eq 0 ]
  [ -L "${HOME}/.claude/CLAUDE.md" ]
  [ -f "${HOME}/.claude/CLAUDE.local.md" ]
  [ "$(cat "${HOME}/.claude/CLAUDE.local.md")" = "existing content" ]
}

@test "claudecode.sh --help shows usage information" {
  run "${CLAUDECODE_SCRIPT}" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"Link Claude Code configuration files"* ]]
  [[ "$output" == *"-h, --help"* ]]
}

@test "claudecode.sh -h shows usage information" {
  run "${CLAUDECODE_SCRIPT}" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"Link Claude Code configuration files"* ]]
  [[ "$output" == *"-h, --help"* ]]
}

@test "claudecode.sh with unknown option shows error and help" {
  run "${CLAUDECODE_SCRIPT}" --invalid-option
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option: --invalid-option"* ]]
  [[ "$output" == *"Usage:"* ]]
}

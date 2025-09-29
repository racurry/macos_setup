#!/usr/bin/env bats

load '../helpers/common_test_helper.bash'

setup() {
  TEST_TMPDIR="$(mktemp -d)"
  DOTFILES_SCRIPT="${REPO_ROOT}/scripts/bash/dotfiles.sh"
}

teardown() {
  rm -rf "${TEST_TMPDIR}"
}

@test "dotfiles.sh --help shows usage information" {
  run "${DOTFILES_SCRIPT}" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"Link dotfiles from the dotfiles directory to the home directory"* ]]
  [[ "$output" == *"-h, --help"* ]]
}

@test "dotfiles.sh -h shows usage information" {
  run "${DOTFILES_SCRIPT}" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"Link dotfiles from the dotfiles directory to the home directory"* ]]
  [[ "$output" == *"-h, --help"* ]]
}

@test "dotfiles.sh with unknown option shows error and help" {
  run "${DOTFILES_SCRIPT}" --invalid-option
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option: --invalid-option"* ]]
  [[ "$output" == *"Usage:"* ]]
}
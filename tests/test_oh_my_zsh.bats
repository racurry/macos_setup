#!/usr/bin/env bats

load 'helpers/common_test_helper.bash'

setup() {
  TEST_TMPDIR="$(mktemp -d)"
  OH_MY_ZSH_SCRIPT="${REPO_ROOT}/apps/ohmyzsh/ohmyzsh.sh"
}

teardown() {
  rm -rf "${TEST_TMPDIR}"
}

@test "oh_my_zsh.sh --help shows usage information" {
  run "${OH_MY_ZSH_SCRIPT}" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"Install Oh My Zsh shell framework if not already present"* ]]
  [[ "$output" == *"-h, --help"* ]]
}

@test "oh_my_zsh.sh -h shows usage information" {
  run "${OH_MY_ZSH_SCRIPT}" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"Install Oh My Zsh shell framework if not already present"* ]]
  [[ "$output" == *"-h, --help"* ]]
}

@test "oh_my_zsh.sh with unknown option shows error and help" {
  run "${OH_MY_ZSH_SCRIPT}" --invalid-option
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option: --invalid-option"* ]]
  [[ "$output" == *"Usage:"* ]]
}
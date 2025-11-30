#!/usr/bin/env bats

load 'helpers/common_test_helper.bash'

setup() {
  TEST_TMPDIR="$(mktemp -d)"
}

teardown() {
  rm -rf "${TEST_TMPDIR}"
}

@test "log_info prints the message with tag" {
  run log_info "hello world"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[test] hello world"* ]]
}

@test "log_warn writes to stderr" {
  run log_warn "pay attention"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[test] pay attention"* ]]
}

@test "log_error writes to stderr" {
  run log_error "something went wrong"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[test] something went wrong"* ]]
}

@test "require_command succeeds when command exists" {
  run require_command "printf"
  [ "$status" -eq 0 ]
}

@test "require_command fails when command is missing" {
  run require_command "definitely-not-a-command"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Required command 'definitely-not-a-command' not found"* ]]
}

@test "require_file succeeds when file exists" {
  local file="${TEST_TMPDIR}/example.txt"
  printf '%s' "data" >"${file}"
  run require_file "${file}"
  [ "$status" -eq 0 ]
}

@test "require_file fails when file missing" {
  local file="${TEST_TMPDIR}/missing.txt"
  run require_file "${file}"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Required file '${file}' is missing"* ]]
}

@test "require_directory succeeds when directory exists" {
  local dir="${TEST_TMPDIR}/dir"
  mkdir -p "${dir}"
  run require_directory "${dir}"
  [ "$status" -eq 0 ]
}

@test "require_directory fails when directory missing" {
  local dir="${TEST_TMPDIR}/missing-dir"
  run require_directory "${dir}"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Required directory '${dir}' is missing"* ]]
}

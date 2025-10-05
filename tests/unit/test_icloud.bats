#!/usr/bin/env bats

# shellcheck source=lib/bash/paths.sh
source "${BATS_TEST_DIRNAME}/../../lib/bash/paths.sh"

setup() {
  TEST_TMPDIR="$(mktemp -d)"
  ORIGINAL_HOME="${HOME:-}"
  export HOME="${TEST_TMPDIR}/home"
  mkdir -p "${HOME}"
  SCRIPT_PATH="${BATS_TEST_DIRNAME}/../../scripts/bash/icloud.sh"
  ICLOUD_SOURCE="${SETUP_PATH_ICLOUD_MOBILE_DOCUMENTS}"
  TARGET_LINK="${SETUP_PATH_ICLOUD}"
}

teardown() {
  rm -rf "${TEST_TMPDIR}"
  if [[ -n "${ORIGINAL_HOME}" ]]; then
    export HOME="${ORIGINAL_HOME}"
  else
    unset HOME
  fi
}

@test "link_icloud skips when source missing" {
  run env HOME="${HOME}" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
  [[ "$output" == *"iCloud Drive not found"* ]]
  [ ! -e "${TARGET_LINK}" ]
}

@test "link_icloud creates symlink when source present" {
  mkdir -p "${ICLOUD_SOURCE}"
  run env HOME="${HOME}" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
  [ -L "${TARGET_LINK}" ]
  [[ "$(readlink "${TARGET_LINK}")" == "${ICLOUD_SOURCE}" ]]
}

@test "link_icloud leaves existing symlink pointing correctly" {
  mkdir -p "${ICLOUD_SOURCE}"
  ln -s "${ICLOUD_SOURCE}" "${TARGET_LINK}"
  run env HOME="${HOME}" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
  [ -L "${TARGET_LINK}" ]
  [[ "$(readlink "${TARGET_LINK}")" == "${ICLOUD_SOURCE}" ]]
}

@test "link_icloud fails when target exists and is not symlink" {
  mkdir -p "${ICLOUD_SOURCE}"
  echo "conflict" > "${TARGET_LINK}"
  run env HOME="${HOME}" "${SCRIPT_PATH}"
  [ "$status" -eq 1 ]
  [ ! -L "${TARGET_LINK}" ]
  [[ "$(cat "${TARGET_LINK}")" == "conflict" ]]
}

@test "icloud.sh --help shows usage information" {
  run "${SCRIPT_PATH}" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"Create a symbolic link from ~/iCloud to the iCloud Drive directory"* ]]
  [[ "$output" == *"-h, --help"* ]]
}

@test "icloud.sh -h shows usage information" {
  run "${SCRIPT_PATH}" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"Create a symbolic link from ~/iCloud to the iCloud Drive directory"* ]]
  [[ "$output" == *"-h, --help"* ]]
}

@test "icloud.sh with unknown option shows error and help" {
  run "${SCRIPT_PATH}" --invalid-option
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option: --invalid-option"* ]]
  [[ "$output" == *"Usage:"* ]]
}

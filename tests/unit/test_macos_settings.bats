#!/usr/bin/env bats

setup() {
    # Get the project root directory (two levels up from tests/unit/)
    TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "${TEST_DIR}/../.." && pwd)"
    SCRIPT_PATH="${PROJECT_ROOT}/scripts/bash/macos_settings.sh"
}

@test "script exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "help argument displays usage information" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "COMMANDS:" ]]
    [[ "$output" =~ "global" ]]
    [[ "$output" =~ "input" ]]
    [[ "$output" =~ "dock" ]]
    [[ "$output" =~ "finder" ]]
    [[ "$output" =~ "misc" ]]
    [[ "$output" =~ "all" ]]
}

@test "short help flag works" {
    run "$SCRIPT_PATH" -h
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
}

@test "help command works" {
    run "$SCRIPT_PATH" help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
}

@test "no arguments shows error and suggests help" {
    run "$SCRIPT_PATH"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Error: No command specified" ]]
    [[ "$output" =~ "--help" ]]
}

@test "invalid command shows error and suggests help" {
    run "$SCRIPT_PATH" invalid_command
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Error: Unknown command 'invalid_command'" ]]
    [[ "$output" =~ "--help" ]]
}

@test "help output contains examples section" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "EXAMPLES:" ]]
}

@test "help output contains options section" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "OPTIONS:" ]]
}

@test "help output mentions sudo requirements" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "sudo" ]]
}

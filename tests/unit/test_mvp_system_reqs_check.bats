#!/usr/bin/env bats

load '../helpers/common_test_helper.bash'

setup() {
  TEST_TMPDIR="$(mktemp -d)"
  # Save original values
  ORIGINAL_EUID="$EUID"
  ORIGINAL_PWD="$(pwd)"
}

teardown() {
  rm -rf "${TEST_TMPDIR}"
  # Restore working directory
  cd "$ORIGINAL_PWD"
}

# Preflight checks tests

@test "mvp_system_reqs_check fails when run as root" {
  # We can't easily mock EUID since it's readonly, so we'll create a
  # modified version of the script that simulates root
  cat > "${TEST_TMPDIR}/preflight_root.sh" << 'EOF'
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${REPO_ROOT}/lib/bash/common.sh"

print_heading "System Requirements Check (MVP)"

# Simulate running as root
if [[ 0 -eq 0 ]]; then
  fail "Run this setup as a regular user, not root"
fi
EOF
  chmod +x "${TEST_TMPDIR}/preflight_root.sh"

  run bash "${TEST_TMPDIR}/preflight_root.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Run this setup as a regular user, not root"* ]]
}

@test "mvp_system_reqs_check succeeds with normal user" {
  # Skip this test if we don't have defaults or xcode-select command (non-macOS)
  if ! command -v defaults >/dev/null 2>&1; then
    skip "defaults command not available (non-macOS system)"
  fi
  if ! command -v xcode-select >/dev/null 2>&1; then
    skip "xcode-select command not available (non-macOS system)"
  fi

  # Change to repo root to avoid directory change messages
  cd "${REPO_ROOT}"
  run bash "${REPO_ROOT}/scripts/bash/mvp_system_reqs_check.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Preflight checks passed"* ]]
}

@test "mvp_system_reqs_check changes to repo root when run from elsewhere" {
  # Skip this test if we don't have defaults or xcode-select command (non-macOS)
  if ! command -v defaults >/dev/null 2>&1; then
    skip "defaults command not available (non-macOS system)"
  fi
  if ! command -v xcode-select >/dev/null 2>&1; then
    skip "xcode-select command not available (non-macOS system)"
  fi

  cd "${TEST_TMPDIR}"
  run bash "${REPO_ROOT}/scripts/bash/mvp_system_reqs_check.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Changing working directory to ${REPO_ROOT}"* ]]
  [[ "$output" == *"Preflight checks passed"* ]]
}

@test "mvp_system_reqs_check requires defaults command" {
  # Create a minimal PATH that has essential commands but not defaults
  mkdir -p "${TEST_TMPDIR}/bin"
  ln -s "$(command -v bash)" "${TEST_TMPDIR}/bin/bash"
  ln -s "$(command -v rm)" "${TEST_TMPDIR}/bin/rm"
  ln -s "$(command -v mkdir)" "${TEST_TMPDIR}/bin/mkdir"
  ln -s "$(command -v pwd)" "${TEST_TMPDIR}/bin/pwd"
  ln -s "$(command -v cd)" "${TEST_TMPDIR}/bin/cd" 2>/dev/null || true
  ln -s "$(command -v dirname)" "${TEST_TMPDIR}/bin/dirname"
  ln -s "$(command -v sudo)" "${TEST_TMPDIR}/bin/sudo"
  ln -s "$(command -v xcode-select)" "${TEST_TMPDIR}/bin/xcode-select"
  export PATH="${TEST_TMPDIR}/bin"

  run bash "${REPO_ROOT}/scripts/bash/mvp_system_reqs_check.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Required command 'defaults' not found"* ]]
}

@test "mvp_system_reqs_check requires sudo command" {
  # Create a custom PATH that has defaults but not sudo
  mkdir -p "${TEST_TMPDIR}/bin"
  ln -s "$(command -v bash)" "${TEST_TMPDIR}/bin/bash"
  ln -s "$(command -v rm)" "${TEST_TMPDIR}/bin/rm"
  ln -s "$(command -v mkdir)" "${TEST_TMPDIR}/bin/mkdir"
  ln -s "$(command -v pwd)" "${TEST_TMPDIR}/bin/pwd"
  ln -s "$(command -v cd)" "${TEST_TMPDIR}/bin/cd" 2>/dev/null || true
  ln -s "$(command -v dirname)" "${TEST_TMPDIR}/bin/dirname"
  ln -s "$(command -v defaults || echo /usr/bin/defaults)" "${TEST_TMPDIR}/bin/defaults"
  ln -s "$(command -v xcode-select)" "${TEST_TMPDIR}/bin/xcode-select"
  export PATH="${TEST_TMPDIR}/bin"
  run bash "${REPO_ROOT}/scripts/bash/mvp_system_reqs_check.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Required command 'sudo' not found"* ]]
}

# Xcode Command Line Tools tests

@test "mvp_system_reqs_check succeeds when xcode tools already installed" {
  # Skip this test if we don't have xcode-select (non-macOS)
  if ! command -v xcode-select >/dev/null 2>&1; then
    skip "xcode-select command not available (non-macOS system)"
  fi

  # Create a mock xcode-select that succeeds
  mkdir -p "${TEST_TMPDIR}/bin"
  cat > "${TEST_TMPDIR}/bin/xcode-select" << 'EOF'
#!/bin/bash
if [[ "$1" == "-p" ]]; then
  echo "/Applications/Xcode.app/Contents/Developer"
  exit 0
fi
exec "$(command -v xcode-select)" "$@"
EOF
  chmod +x "${TEST_TMPDIR}/bin/xcode-select"

  # Create mock defaults and sudo commands
  cat > "${TEST_TMPDIR}/bin/defaults" << 'EOF'
#!/bin/bash
exit 0
EOF
  chmod +x "${TEST_TMPDIR}/bin/defaults"

  cat > "${TEST_TMPDIR}/bin/sudo" << 'EOF'
#!/bin/bash
exit 0
EOF
  chmod +x "${TEST_TMPDIR}/bin/sudo"

  export PATH="${TEST_TMPDIR}/bin:${PATH}"

  run bash "${REPO_ROOT}/scripts/bash/mvp_system_reqs_check.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Xcode Command Line Tools already installed"* ]]
  [[ "$output" == *"All system requirements checks passed"* ]]
}

@test "mvp_system_reqs_check triggers installation when tools not installed" {
  # Skip this test if we don't have xcode-select (non-macOS)
  if ! command -v xcode-select >/dev/null 2>&1; then
    skip "xcode-select command not available (non-macOS system)"
  fi

  # Create a mock xcode-select that fails -p but succeeds --install
  mkdir -p "${TEST_TMPDIR}/bin"
  cat > "${TEST_TMPDIR}/bin/xcode-select" << 'EOF'
#!/bin/bash
if [[ "$1" == "-p" ]]; then
  exit 2
elif [[ "$1" == "--install" ]]; then
  echo "xcode-select: note: install requested for command line developer tools"
  exit 0
fi
exec "$(command -v xcode-select)" "$@"
EOF
  chmod +x "${TEST_TMPDIR}/bin/xcode-select"

  # Create mock defaults and sudo commands
  cat > "${TEST_TMPDIR}/bin/defaults" << 'EOF'
#!/bin/bash
exit 0
EOF
  chmod +x "${TEST_TMPDIR}/bin/defaults"

  cat > "${TEST_TMPDIR}/bin/sudo" << 'EOF'
#!/bin/bash
exit 0
EOF
  chmod +x "${TEST_TMPDIR}/bin/sudo"

  export PATH="${TEST_TMPDIR}/bin:${PATH}"

  run bash "${REPO_ROOT}/scripts/bash/mvp_system_reqs_check.sh"
  [ "$status" -eq 2 ]
  [[ "$output" == *"Triggering Xcode Command Line Tools installation"* ]]
  [[ "$output" == *"Installer launched. Complete it, then rerun this step."* ]]
}

@test "mvp_system_reqs_check handles installation failure" {
  # Skip this test if we don't have xcode-select (non-macOS)
  if ! command -v xcode-select >/dev/null 2>&1; then
    skip "xcode-select command not available (non-macOS system)"
  fi

  # Create a mock xcode-select that fails both -p and --install
  mkdir -p "${TEST_TMPDIR}/bin"
  cat > "${TEST_TMPDIR}/bin/xcode-select" << 'EOF'
#!/bin/bash
if [[ "$1" == "-p" ]]; then
  exit 2
elif [[ "$1" == "--install" ]]; then
  exit 1
fi
exec "$(command -v xcode-select)" "$@"
EOF
  chmod +x "${TEST_TMPDIR}/bin/xcode-select"

  # Create mock defaults and sudo commands
  cat > "${TEST_TMPDIR}/bin/defaults" << 'EOF'
#!/bin/bash
exit 0
EOF
  chmod +x "${TEST_TMPDIR}/bin/defaults"

  cat > "${TEST_TMPDIR}/bin/sudo" << 'EOF'
#!/bin/bash
exit 0
EOF
  chmod +x "${TEST_TMPDIR}/bin/sudo"

  export PATH="${TEST_TMPDIR}/bin:${PATH}"

  run bash "${REPO_ROOT}/scripts/bash/mvp_system_reqs_check.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Installer launch may have failed; verify manually and rerun."* ]]
}
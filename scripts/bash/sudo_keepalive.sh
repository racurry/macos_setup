#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

print_heading "Sudo keep-alive"

require_command sudo

log_info "Requesting sudo credentials"
if ! sudo -v; then
  fail "Sudo authentication failed"
fi

# Refresh sudo timestamp in the background until this script exits.
log_info "Starting sudo keep-alive loop"
while true; do
  sleep 60
  sudo -n true || break
done &
KEEPALIVE_PID=$!

# Ensure we stop the background loop when this process exits.
cleanup() {
  if kill -0 "$KEEPALIVE_PID" >/dev/null 2>&1; then
    kill "$KEEPALIVE_PID"
  fi
}
trap cleanup EXIT

log_info "Sudo keep-alive running"

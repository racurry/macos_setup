#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../lib/bash/common.sh"

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Pull the latest changes from the remote repository, handling local changes gracefully.

Behavior:
  - Checks current branch and remote status
  - Auto-stashes any local changes
  - Pulls latest changes from remote
  - Pops stash if changes were stashed

Options:
  -h, --help    Show this help message

Examples:
  ./scripts/bash/update_repo.sh
EOF
}

# Parse arguments
case ${1:-} in
  -h|--help)
    show_help
    exit 0
    ;;
esac

print_heading "Updating Repository"

# Change to repository root
cd "${REPO_ROOT}"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  fail "Not in a git repository"
fi

# Get current branch
CURRENT_BRANCH="$(git branch --show-current)"
log_info "Current branch: ${CURRENT_BRANCH}"

# Check for uncommitted changes
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
  log_warn "Uncommitted changes detected - stashing"
  git stash push -u -m "Auto-stash before update_repo.sh on $(date '+%Y-%m-%d %H:%M:%S')"
  STASHED=true
else
  STASHED=false
  log_info "Working directory clean"
fi

# Fetch latest changes
log_info "Fetching latest changes from remote..."
git fetch origin

# Check if remote has updates
LOCAL_COMMIT="$(git rev-parse @)"
# shellcheck disable=SC1083
REMOTE_COMMIT="$(git rev-parse '@{u}')"
# shellcheck disable=SC1083
BASE_COMMIT="$(git merge-base @ '@{u}')"

if [[ "${LOCAL_COMMIT}" == "${REMOTE_COMMIT}" ]]; then
  log_info "Already up to date"
elif [[ "${LOCAL_COMMIT}" == "${BASE_COMMIT}" ]]; then
  log_info "Pulling latest changes..."
  git pull --rebase origin "${CURRENT_BRANCH}"
  log_info "✓ Repository updated successfully"
elif [[ "${REMOTE_COMMIT}" == "${BASE_COMMIT}" ]]; then
  log_warn "Local branch is ahead of remote - no changes pulled"
else
  log_warn "Branches have diverged - attempting rebase"
  git pull --rebase origin "${CURRENT_BRANCH}"
  log_info "✓ Repository updated successfully"
fi

# Pop stash if we stashed changes
if [[ "${STASHED}" == "true" ]]; then
  log_info "Restoring stashed changes..."
  if git stash pop; then
    log_info "✓ Stashed changes restored"
  else
    log_warn "Stash pop had conflicts - resolve manually with: git stash pop"
    exit 2
  fi
fi

log_info "✓ Update complete"

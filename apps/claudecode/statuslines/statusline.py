#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Claude Code status line - user@host:dir (branch*)"""

# ANSI color codes
RESET = "\033[0m"
BOLD = "\033[1m"
BLACK = "\033[30m"
RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
MAGENTA = "\033[35m"
CYAN = "\033[36m"
WHITE = "\033[37m"
BG_BLACK = "\033[40m"
BG_RED = "\033[41m"
BG_GREEN = "\033[42m"
BG_YELLOW = "\033[43m"
BG_BLUE = "\033[44m"
BG_MAGENTA = "\033[45m"
BG_CYAN = "\033[46m"
BG_WHITE = "\033[47m"

import json
import os
import socket
import subprocess
import sys


def get_git_info(cwd: str) -> str:
    """Get git branch and dirty status if in a git repo."""
    try:
        subprocess.run(
            ["git", "-C", cwd, "rev-parse", "--git-dir"],
            capture_output=True,
            check=True,
        )
    except subprocess.CalledProcessError:
        return ""

    # Get branch name
    result = subprocess.run(
        ["git", "-C", cwd, "branch", "--show-current"],
        capture_output=True,
        text=True,
    )
    branch = result.stdout.strip() or "detached"

    # Check for uncommitted changes
    diff_result = subprocess.run(
        ["git", "-C", cwd, "diff", "--quiet"],
        capture_output=True,
    )
    cached_result = subprocess.run(
        ["git", "-C", cwd, "diff", "--cached", "--quiet"],
        capture_output=True,
    )
    status = "*" if diff_result.returncode != 0 or cached_result.returncode != 0 else ""

    return f" ({branch}{status})"


def main() -> None:
    data = json.load(sys.stdin)
    cwd = data.get("workspace", {}).get("current_dir", os.getcwd())

    user = os.environ.get("USER", "unknown")
    host = socket.gethostname().split(".")[0]
    model = data.get("model", {}).get("display_name", "unknown")
    directory = os.path.basename(cwd)
    git_info = get_git_info(cwd)

    print(f"{BG_BLUE}🤖{WHITE}{model}{RESET} {GREEN}{git_info}{RESET}")


if __name__ == "__main__":
    main()


# Reference from https://code.claude.com/docs/en/statusline#status-line-configuration
# {
#   "hook_event_name": "Status",
#   "session_id": "abc123...",
#   "transcript_path": "/path/to/transcript.json",
#   "cwd": "/current/working/directory",
#   "model": {
#     "id": "claude-opus-4-1",
#     "display_name": "Opus"
#   },
#   "workspace": {
#     "current_dir": "/current/working/directory",
#     "project_dir": "/original/project/directory"
#   },
#   "version": "1.0.80",
#   "output_style": {
#     "name": "default"
#   },
#   "cost": {
#     "total_cost_usd": 0.01234,
#     "total_duration_ms": 45000,
#     "total_api_duration_ms": 2300,
#     "total_lines_added": 156,
#     "total_lines_removed": 23
#   }
# }

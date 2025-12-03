#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Claude Code status line"""

# =============================================================================
# STATUS HOOK INPUT SCHEMA
# =============================================================================
# Claude Code passes this JSON to status line scripts via stdin.
# Docs: https://code.claude.com/docs/en/statusline
#
# {
#   "session_id": "uuid-string",           # Current session identifier
#   "transcript_path": "/path/to/x.jsonl", # Full path to session transcript
#   "cwd": "/current/working/directory",   # Current working directory
#   "version": "2.0.57",                   # Claude Code version
#
#   "model": {
#     "id": "claude-opus-4-5-20251101",    # Full model identifier
#     "display_name": "Opus 4.5"           # Human-friendly model name
#   },
#
#   "workspace": {
#     "current_dir": "/current/dir",       # Current working directory
#     "project_dir": "/project/root"       # Original project directory
#   },
#
#   "output_style": {
#     "name": "default"                    # Active output style name
#   },
#
#   "cost": {
#     "total_cost_usd": 0.88,              # Session cost in USD
#     "total_duration_ms": 647287,         # Total session duration
#     "total_api_duration_ms": 165204,     # Time spent in API calls
#     "total_lines_added": 28,             # Lines added this session
#     "total_lines_removed": 1             # Lines removed this session
#   },
#
#   "exceeds_200k_tokens": false           # UNDOCUMENTED: context size warning
# }
#
# Note: "hook_event_name": "Status" appears in docs but not in actual data.
# =============================================================================

import json
import os
import subprocess
import sys

# Token limit for context window (Claude models)
MAX_CONTEXT_TOKENS = 200_000

# ANSI escape codes
# Reset
RESET = "\033[0m"

# Text attributes
BOLD = "\033[1m"
DIM = "\033[2m"
ITALIC = "\033[3m"
UNDERLINE = "\033[4m"
BLINK = "\033[5m"
REVERSE = "\033[7m"
STRIKETHROUGH = "\033[9m"

# Standard foreground colors (30-37)
BLACK = "\033[30m"
RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
MAGENTA = "\033[35m"
CYAN = "\033[36m"
WHITE = "\033[37m"

# Standard background colors (40-47)
BG_BLACK = "\033[40m"
BG_RED = "\033[41m"
BG_GREEN = "\033[42m"
BG_YELLOW = "\033[43m"
BG_BLUE = "\033[44m"
BG_MAGENTA = "\033[45m"
BG_CYAN = "\033[46m"
BG_WHITE = "\033[47m"

# Bright foreground colors (90-97)
BRIGHT_BLACK = "\033[90m"  # gray
BRIGHT_RED = "\033[91m"
BRIGHT_GREEN = "\033[92m"
BRIGHT_YELLOW = "\033[93m"
BRIGHT_BLUE = "\033[94m"
BRIGHT_MAGENTA = "\033[95m"
BRIGHT_CYAN = "\033[96m"
BRIGHT_WHITE = "\033[97m"

# Bright background colors (100-107)
BG_BRIGHT_BLACK = "\033[100m"
BG_BRIGHT_RED = "\033[101m"
BG_BRIGHT_GREEN = "\033[102m"
BG_BRIGHT_YELLOW = "\033[103m"
BG_BRIGHT_BLUE = "\033[104m"
BG_BRIGHT_MAGENTA = "\033[105m"
BG_BRIGHT_CYAN = "\033[106m"
BG_BRIGHT_WHITE = "\033[107m"

# =============================================================================
# SCHEMA DISCOVERY LOGGING (disabled)
# =============================================================================
# To discover new/undocumented fields in the status hook data:
#   1. Uncomment the LOG_PATH, LOG_SAMPLES, and log_stdin_sample() below
#   2. Uncomment the log_stdin_sample(raw_input) call in main()
#   3. Use Claude Code normally - samples will collect at LOG_PATH
#   4. Inspect with: cat /tmp/claude_status_samples.jsonl | python3 -m json.tool
#   5. Delete log file to collect fresh samples: rm /tmp/claude_status_samples.jsonl
#
# LOG_PATH = "/tmp/claude_status_samples.jsonl"
# LOG_SAMPLES = 10  # Number of samples to collect before stopping
#
#
# def log_stdin_sample(raw_input: str) -> None:
#     """Log raw stdin to file for discovering available fields."""
#     try:
#         # Count existing samples
#         sample_count = 0
#         if os.path.exists(LOG_PATH):
#             with open(LOG_PATH) as f:
#                 sample_count = sum(1 for _ in f)
#
#         # Only log up to LOG_SAMPLES
#         if sample_count < LOG_SAMPLES:
#             with open(LOG_PATH, "a") as f:
#                 entry = {
#                     "timestamp": datetime.datetime.now().isoformat(),
#                     "data": json.loads(raw_input),
#                 }
#                 f.write(json.dumps(entry) + "\n")
#     except Exception:
#         pass  # Silently fail - don't break status line


def get_context_usage(transcript_path: str) -> tuple[int, float] | None:
    """
    Calculate token usage from transcript file.

    Reads the transcript JSONL and finds the most recent main-chain entry
    with usage data. Returns (total_tokens, percentage) or None if unavailable.

    Based on: https://codelynx.dev/posts/calculate-claude-code-context
    """
    if not transcript_path or not os.path.exists(transcript_path):
        return None

    latest_usage = None
    latest_timestamp = ""

    try:
        with open(transcript_path) as f:
            for line in f:
                try:
                    entry = json.loads(line)

                    # Skip non-main-chain entries
                    if entry.get("isSidechain"):
                        continue
                    if entry.get("isApiErrorMessage"):
                        continue

                    # Get usage data from message
                    usage = entry.get("message", {}).get("usage")
                    if not usage:
                        continue

                    # Track most recent by timestamp
                    timestamp = entry.get("timestamp", "")
                    if timestamp >= latest_timestamp:
                        latest_timestamp = timestamp
                        latest_usage = usage

                except json.JSONDecodeError:
                    continue

        if latest_usage:
            # Sum all token types that count toward context
            total = (
                latest_usage.get("input_tokens", 0)
                + latest_usage.get("cache_read_input_tokens", 0)
                + latest_usage.get("cache_creation_input_tokens", 0)
            )
            percentage = (total / MAX_CONTEXT_TOKENS) * 100
            return total, percentage

    except Exception:
        pass

    return None


def format_context_display(tokens: int, percentage: float) -> str:
    """Format context usage with color coding based on utilization."""
    # Color based on usage level
    if percentage >= 85:
        color = RED
    elif percentage >= 70:
        color = YELLOW
    else:
        color = GREEN

    # Format tokens as "123k" for readability
    if tokens >= 1000:
        tokens_str = f"{tokens // 1000}k"
    else:
        tokens_str = str(tokens)

    return f"{color}{tokens_str} ({percentage:.0f}%){RESET}"


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
    is_dirty = diff_result.returncode != 0 or cached_result.returncode != 0
    dirty_indicator = f"{YELLOW}*{RESET}" if is_dirty else ""

    return f"{BLUE}{branch}{RESET}{dirty_indicator}"


def main() -> None:
    raw_input = sys.stdin.read()
    # log_stdin_sample(raw_input)  # Uncomment to enable schema discovery logging
    data = json.loads(raw_input)
    cwd = data.get("workspace", {}).get("current_dir", os.getcwd())
    model = data.get("model", {}).get("display_name", "unknown")
    transcript_path = data.get("transcript_path", "")
    git_info = get_git_info(cwd)

    # Build status line components
    parts = []
    # Add git info (already has colors applied)
    if git_info:
        parts.append(git_info)

    parts.append(f"{WHITE}🤖{model}{RESET}")

    # Add context usage if available
    context = get_context_usage(transcript_path)
    if context:
        tokens, percentage = context
        parts.append(format_context_display(tokens, percentage))

    print(" ".join(parts))


if __name__ == "__main__":
    main()

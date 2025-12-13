#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Claude Code status line with rich git info."""

# =============================================================================
# CONFIGURATION
# =============================================================================
# Style options: "pipes", "diamonds", "labeled", "powerline", "dots"
#   pipes:     Minimal separators (│)
#   diamonds:  Symbol-heavy separators (◆)
#   labeled:   Compact with dimmed labels
#   powerline: Colored background segments
#   dots:      Subtle dot separators (·)
DEFAULT_STYLE = "powerline"

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
#   "version": "2.0.67",                   # Claude Code version
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
#   # --- UNDOCUMENTED FIELDS (discovered via schema logging) -----------------
#   # These fields are not in official docs but appear in actual hook data.
#   # Use --log to discover new fields as Claude Code evolves.
#
#   "context_window": {
#     "total_input_tokens": 32501,         # Input tokens used
#     "total_output_tokens": 34054,        # Output tokens used
#     "context_window_size": 200000        # Max context window size
#   },
#
#   "exceeds_200k_tokens": false           # Context exhaustion warning
# }
#
# Note: "hook_event_name": "Status" appears in docs but not in actual data.
# =============================================================================

import argparse
import json
import os
import subprocess
import sys
from dataclasses import dataclass

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


# Schema discovery logging - see log_stdin_sample() docstring for usage
LOG_PATH = "/tmp/claude_status_samples.jsonl"
LOG_SAMPLES = 10


def log_stdin_sample(raw_input: str) -> None:
    """
    Log raw status hook stdin to file for schema discovery.

    Claude Code's status hook JSON contains undocumented fields that can be
    useful for status line display. This function captures samples so we can
    discover new fields as Claude Code evolves.

    The workflow:
      1. Enable with --log flag in hooks.json statusline config
      2. Samples collect at /tmp/claude_status_samples.jsonl
      3. After using Claude Code, inspect: cat <LOG_PATH> | python3 -m json.tool
      4. Compare against https://code.claude.com/docs/en/statusline
      5. Undocumented fields = new features we can use!

    Examples of fields discovered this way:
      - context_window.total_input_tokens (direct token count!)
      - context_window.context_window_size (dynamic, not hardcoded)

    Limits to LOG_SAMPLES entries to avoid unbounded growth.
    Silently fails to never break the status line display.
    """
    import datetime

    try:
        # Count existing samples
        sample_count = 0
        if os.path.exists(LOG_PATH):
            with open(LOG_PATH) as f:
                sample_count = sum(1 for _ in f)

        # Only log up to LOG_SAMPLES
        if sample_count < LOG_SAMPLES:
            with open(LOG_PATH, "a") as f:
                entry = {
                    "timestamp": datetime.datetime.now().isoformat(),
                    "data": json.loads(raw_input),
                }
                f.write(json.dumps(entry) + "\n")
    except Exception:
        pass  # Silently fail - don't break status line


# =============================================================================
# DATA STRUCTURES
# =============================================================================
@dataclass
class GitInfo:
    """Raw git repository state."""

    branch: str = "detached"
    ahead: int = 0
    behind: int = 0
    has_upstream: bool = False
    has_staged: bool = False
    has_unstaged: bool = False


@dataclass
class ContextInfo:
    """Context window usage."""

    tokens: int = 0
    percentage: float = 0.0


# =============================================================================
# DATA COLLECTION
# =============================================================================
def get_git_info(cwd: str) -> GitInfo | None:
    """Get git repository state using single porcelain call."""
    result = subprocess.run(
        ["git", "-C", cwd, "status", "--porcelain=v2", "--branch"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return None

    info = GitInfo()

    for line in result.stdout.splitlines():
        if line.startswith("# branch.head "):
            info.branch = line[14:] or "detached"
        elif line.startswith("# branch.upstream "):
            info.has_upstream = True
        elif line.startswith("# branch.ab "):
            parts = line[12:].split()
            if len(parts) >= 2:
                info.ahead = int(parts[0].lstrip("+"))
                info.behind = abs(int(parts[1]))
        elif line and not line.startswith("#"):
            if line.startswith("? "):
                info.has_unstaged = True
            elif len(line) > 4:
                xy = line[2:4]
                if xy[0] != ".":
                    info.has_staged = True
                if xy[1] != ".":
                    info.has_unstaged = True

    return info


def get_context_usage(data: dict) -> ContextInfo | None:
    """
    Extract context window usage from status hook data.

    Uses the undocumented 'context_window' field which provides direct token
    counts - no need to parse the transcript file! Discovered via schema logging.

    Args:
        data: The full status hook JSON data dict

    Returns:
        ContextInfo with token count and percentage, or None if unavailable
    """
    ctx = data.get("context_window")
    if not ctx:
        return None

    tokens = ctx.get("total_input_tokens", 0)
    max_tokens = ctx.get("context_window_size", 200_000)  # Fallback if missing

    if tokens and max_tokens:
        return ContextInfo(tokens=tokens, percentage=(tokens / max_tokens) * 100)

    return None


# =============================================================================
# STYLE FORMATTERS
# =============================================================================
def format_tokens(tokens: int) -> str:
    """Format token count as human-readable string."""
    return f"{tokens // 1000}k" if tokens >= 1000 else str(tokens)


def context_color(percentage: float) -> str:
    """Get color code based on context usage percentage."""
    if percentage >= 85:
        return RED
    elif percentage >= 70:
        return YELLOW
    return GREEN


def format_style_pipes(git: GitInfo | None, model: str, ctx: ContextInfo | None) -> str:
    """Style: Minimal separators with │"""
    parts = []

    # Git section
    if git:
        git_parts = [f"{BLUE}{git.branch}{RESET}"]
        if git.ahead:
            git_parts.append(f"{GREEN}↑{git.ahead}{RESET}")
        if git.behind:
            git_parts.append(f"{RED}↓{git.behind}{RESET}")
        if git.has_staged:
            git_parts.append(f"{GREEN}●{RESET}")
        if git.has_unstaged:
            git_parts.append(f"{YELLOW}○{RESET}")
        if git.branch != "detached" and not git.has_upstream:
            git_parts.append(f"{RED}⚠{RESET}")
        parts.append(" ".join(git_parts))

    # Model section
    parts.append(f"{WHITE}{model}{RESET}")

    # Context section
    if ctx:
        color = context_color(ctx.percentage)
        parts.append(f"{color}{format_tokens(ctx.tokens)} ({ctx.percentage:.0f}%){RESET}")

    return f" {DIM}│{RESET} ".join(parts)


def format_style_diamonds(git: GitInfo | None, model: str, ctx: ContextInfo | None) -> str:
    """Style: Symbol-heavy separators with ◆"""
    parts = []

    # Git section
    if git:
        git_parts = [f"{BLUE}{git.branch}{RESET}"]
        if git.ahead:
            git_parts.append(f"{GREEN}↑{git.ahead}{RESET}")
        if git.behind:
            git_parts.append(f"{RED}↓{git.behind}{RESET}")
        if git.has_staged:
            git_parts.append(f"{GREEN}●{RESET}")
        if git.has_unstaged:
            git_parts.append(f"{YELLOW}○{RESET}")
        if git.branch != "detached" and not git.has_upstream:
            git_parts.append(f"{RED}⚠{RESET}")
        parts.append(" ".join(git_parts))

    # Model section
    parts.append(f"{WHITE}{model}{RESET}")

    # Context section
    if ctx:
        color = context_color(ctx.percentage)
        parts.append(f"{color}{format_tokens(ctx.tokens)}/{ctx.percentage:.0f}%{RESET}")

    return f" {DIM}◆{RESET} ".join(parts)


def format_style_labeled(git: GitInfo | None, model: str, ctx: ContextInfo | None) -> str:
    """Style: Compact with dimmed labels"""
    parts = []

    # Git section (no label, it's obvious)
    if git:
        git_parts = [f"{BLUE}{git.branch}{RESET}"]
        if git.ahead:
            git_parts.append(f"{GREEN}↑{git.ahead}{RESET}")
        if git.behind:
            git_parts.append(f"{RED}↓{git.behind}{RESET}")
        if git.has_staged:
            git_parts.append(f"{GREEN}●{RESET}")
        if git.has_unstaged:
            git_parts.append(f"{YELLOW}○{RESET}")
        if git.branch != "detached" and not git.has_upstream:
            git_parts.append(f"{RED}⚠{RESET}")
        parts.append(" ".join(git_parts))

    # Model section with label
    parts.append(f"{DIM}model:{RESET}{WHITE}{model}{RESET}")

    # Context section with label
    if ctx:
        color = context_color(ctx.percentage)
        parts.append(f"{DIM}ctx:{RESET}{color}{format_tokens(ctx.tokens)}/{ctx.percentage:.0f}%{RESET}")

    return "  ".join(parts)


def format_style_powerline(git: GitInfo | None, model: str, ctx: ContextInfo | None) -> str:
    """Style: Powerline-style colored backgrounds"""
    parts = []

    # Git section - blue background, black text
    if git:
        git_str = f" {git.branch}"
        if git.ahead:
            git_str += f" ↑{git.ahead}"
        if git.behind:
            git_str += f" ↓{git.behind}"
        if git.has_staged:
            git_str += " ●"
        if git.has_unstaged:
            git_str += " ○"
        if git.branch != "detached" and not git.has_upstream:
            git_str += " ⚠"
        git_str += " "
        parts.append(f"{BG_BRIGHT_BLUE}{BLACK}{git_str}{RESET}")

    # Model section - magenta background, black text
    parts.append(f"{BG_BRIGHT_MAGENTA}{BLACK} {model} {RESET}")

    # Context section - colored background based on usage, black text
    if ctx:
        if ctx.percentage >= 85:
            bg = BG_BRIGHT_RED
        elif ctx.percentage >= 70:
            bg = BG_BRIGHT_YELLOW
        else:
            bg = BG_BRIGHT_GREEN
        parts.append(f"{bg}{BLACK} {format_tokens(ctx.tokens)} {ctx.percentage:.0f}% {RESET}")

    return "".join(parts)


def format_style_dots(git: GitInfo | None, model: str, ctx: ContextInfo | None) -> str:
    """Style: Subtle dot separators (·)"""
    parts = []

    # Git section
    if git:
        git_parts = [f"{BLUE}{git.branch}{RESET}"]
        if git.ahead:
            git_parts.append(f"{GREEN}↑{git.ahead}{RESET}")
        if git.behind:
            git_parts.append(f"{RED}↓{git.behind}{RESET}")
        if git.has_staged:
            git_parts.append(f"{GREEN}●{RESET}")
        if git.has_unstaged:
            git_parts.append(f"{YELLOW}○{RESET}")
        if git.branch != "detached" and not git.has_upstream:
            git_parts.append(f"{RED}⚠{RESET}")
        parts.append(" ".join(git_parts))

    # Model section
    parts.append(f"{WHITE}{model}{RESET}")

    # Context section
    if ctx:
        color = context_color(ctx.percentage)
        parts.append(f"{color}{format_tokens(ctx.tokens)} ({ctx.percentage:.0f}%){RESET}")

    return f" {DIM}·{RESET} ".join(parts)


FORMATTERS = {
    "pipes": format_style_pipes,
    "diamonds": format_style_diamonds,
    "labeled": format_style_labeled,
    "powerline": format_style_powerline,
    "dots": format_style_dots,
}


# =============================================================================
# MAIN
# =============================================================================
def main() -> None:
    parser = argparse.ArgumentParser(description="Claude Code status line")
    parser.add_argument(
        "--style",
        "-s",
        choices=list(FORMATTERS.keys()),
        default=DEFAULT_STYLE,
        help=f"Status line style (default: {DEFAULT_STYLE})",
    )
    parser.add_argument(
        "--log",
        action="store_true",
        help=f"Log stdin samples to {LOG_PATH} for schema discovery",
    )
    args = parser.parse_args()

    raw_input = sys.stdin.read()
    if args.log:
        log_stdin_sample(raw_input)
    data = json.loads(raw_input)

    cwd = data.get("workspace", {}).get("current_dir", os.getcwd())
    model = data.get("model", {}).get("display_name", "unknown")

    git = get_git_info(cwd)
    ctx = get_context_usage(data)  # Uses undocumented context_window field

    formatter = FORMATTERS[args.style]
    print(formatter(git, model, ctx))


if __name__ == "__main__":
    main()

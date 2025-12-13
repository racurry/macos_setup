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

# =============================================================================
# ANSI STYLING
# =============================================================================
_RESET = "\033[0m"

# Text attributes
_STYLES = {
    "bold": "\033[1m",
    "dim": "\033[2m",
    "italic": "\033[3m",
    "underline": "\033[4m",
    "blink": "\033[5m",
    "reverse": "\033[7m",
    "hidden": "\033[8m",
    "strikethrough": "\033[9m",
}

# Foreground colors (standard 30-37, bright 90-97)
_FG = {
    "black": "\033[30m",
    "red": "\033[31m",
    "green": "\033[32m",
    "yellow": "\033[33m",
    "blue": "\033[34m",
    "magenta": "\033[35m",
    "cyan": "\033[36m",
    "white": "\033[37m",
    "bright_black": "\033[90m",
    "bright_red": "\033[91m",
    "bright_green": "\033[92m",
    "bright_yellow": "\033[93m",
    "bright_blue": "\033[94m",
    "bright_magenta": "\033[95m",
    "bright_cyan": "\033[96m",
    "bright_white": "\033[97m",
}

# Background colors (standard 40-47, bright 100-107)
_BG = {
    "black": "\033[40m",
    "red": "\033[41m",
    "green": "\033[42m",
    "yellow": "\033[43m",
    "blue": "\033[44m",
    "magenta": "\033[45m",
    "cyan": "\033[46m",
    "white": "\033[47m",
    "bright_black": "\033[100m",
    "bright_red": "\033[101m",
    "bright_green": "\033[102m",
    "bright_yellow": "\033[103m",
    "bright_blue": "\033[104m",
    "bright_magenta": "\033[105m",
    "bright_cyan": "\033[106m",
    "bright_white": "\033[107m",
}


def styled(
    text: str,
    fg: str | None = None,
    bg: str | None = None,
    style: str | None = None,
) -> str:
    """
    Apply ANSI styling to text with a single reset.

    Args:
        text: The text to style
        fg: Foreground color (e.g., "red", "bright_blue")
        bg: Background color (e.g., "black", "bright_magenta")
        style: Text style (e.g., "bold", "dim")

    Examples:
        styled("error", fg="red")
        styled(" main ", fg="black", bg="bright_blue")
        styled("│", style="dim")
    """
    codes = []
    if style:
        codes.append(_STYLES[style])
    if fg:
        codes.append(_FG[fg])
    if bg:
        codes.append(_BG[bg])
    if not codes:
        return text
    return f"{''.join(codes)}{text}{_RESET}"


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
    """Get color name based on context usage percentage."""
    if percentage >= 85:
        return "bright_red"
    elif percentage >= 70:
        return "bright_yellow"
    return "bright_green"


def _format_git_inline(git: GitInfo) -> str:
    """Git status with per-element coloring (used by most styles)."""
    parts = [styled(git.branch, fg="blue")]
    if git.ahead:
        parts.append(styled(f"↑{git.ahead}", fg="green"))
    if git.behind:
        parts.append(styled(f"↓{git.behind}", fg="red"))
    if git.has_staged:
        parts.append(styled("●", fg="green"))
    if git.has_unstaged:
        parts.append(styled("○", fg="yellow"))
    if git.branch != "detached" and not git.has_upstream:
        parts.append(styled("⚠", fg="red"))
    return " ".join(parts)


def _format_git_powerline(git: GitInfo) -> str:
    """Git status with single background (powerline style)."""
    s = f" {git.branch}"
    if git.ahead:
        s += f" ↑{git.ahead}"
    if git.behind:
        s += f" ↓{git.behind}"
    if git.has_staged:
        s += " ●"
    if git.has_unstaged:
        s += " ○"
    if git.branch != "detached" and not git.has_upstream:
        s += " ⚠"
    return styled(f"{s} ", fg="black", bg="bright_blue")


@dataclass
class Style:
    """Configuration for a status line style."""

    sep: str  # Separator between sections
    model_fg: str  # Foreground color for model
    ctx_template: str  # Format string for context (use {tokens}, {pct})
    model_bg: str | None = None  # Background color for model (powerline)
    model_prefix: str = ""  # Optional prefix before model (e.g., "model:")
    ctx_prefix: str = ""  # Optional prefix before context (e.g., "ctx:")
    powerline: bool = False  # Use background colors for context


# Style definitions
STYLES: dict[str, Style] = {
    "pipes": Style(
        sep=f" {styled('│', style='dim')} ",
        model_fg="white",
        ctx_template="{tokens} ({pct}%)",
    ),
    "diamonds": Style(
        sep=f" {styled('◆', style='dim')} ",
        model_fg="white",
        ctx_template="{tokens}/{pct}%",
    ),
    "labeled": Style(
        sep="  ",
        model_fg="white",
        ctx_template="{tokens}/{pct}%",
        model_prefix=styled("model:", style="dim"),
        ctx_prefix=styled("ctx:", style="dim"),
    ),
    "powerline": Style(
        sep="",
        model_fg="black",
        model_bg="bright_magenta",
        ctx_template=" {tokens} {pct}% ",
        powerline=True,
    ),
    "dots": Style(
        sep=f" {styled('·', style='dim')} ",
        model_fg="white",
        ctx_template="{tokens} ({pct}%)",
    ),
}


def format_status(
    git: GitInfo | None, model: str, ctx: ContextInfo | None, style_name: str
) -> str:
    """Format status line using the specified style."""
    style = STYLES[style_name]
    parts = []

    # Git section
    if git:
        if style.powerline:
            parts.append(_format_git_powerline(git))
        else:
            parts.append(_format_git_inline(git))

    # Model section (powerline adds padding)
    model_text = f" {model} " if style.powerline else model
    model_styled = styled(model_text, fg=style.model_fg, bg=style.model_bg)
    parts.append(f"{style.model_prefix}{model_styled}")

    # Context section
    if ctx:
        pct_str = f"{ctx.percentage:.0f}"
        tokens_str = format_tokens(ctx.tokens)
        formatted = style.ctx_template.format(tokens=tokens_str, pct=pct_str)
        ctx_col = context_color(ctx.percentage)
        if style.powerline:
            ctx_styled = styled(formatted, fg="black", bg=ctx_col)
        else:
            ctx_styled = styled(formatted, fg=ctx_col)
        parts.append(f"{style.ctx_prefix}{ctx_styled}")

    return style.sep.join(parts)


# =============================================================================
# MAIN
# =============================================================================
def main() -> None:
    parser = argparse.ArgumentParser(description="Claude Code status line")
    parser.add_argument(
        "--style",
        "-s",
        choices=list(STYLES.keys()),
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
    ctx = get_context_usage(data)

    print(format_status(git, model, ctx, args.style))


if __name__ == "__main__":
    main()

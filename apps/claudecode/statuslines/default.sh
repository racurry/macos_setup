#!/bin/bash
# Claude Code status line - user@host:dir (branch*)

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
user=$(whoami)
host=$(hostname -s)
dir=$(basename "$cwd")

git_info=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null || echo "detached")
    if ! git -C "$cwd" diff --quiet 2>/dev/null || ! git -C "$cwd" diff --cached --quiet 2>/dev/null; then
        status="*"
    else
        status=""
    fi
    git_info=" (${branch}${status})"
fi

printf "HEY BRO" "%s@%s:%s%s" "$user" "$host" "$dir" "$git_info"

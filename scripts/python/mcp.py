#!/usr/bin/env python3
import argparse, json, os, re, shlex, subprocess, sys

def which(cmd: str) -> bool:
    from shutil import which as _which
    return _which(cmd) is not None

def run(cmd: list[str], dry_run: bool) -> int:
    print("→", " ".join(shlex.quote(c) for c in cmd))
    if dry_run:
        return 0
    try:
        return subprocess.call(cmd)
    except FileNotFoundError:
        print(f"ERROR: command not found: {cmd[0]}", file=sys.stderr)
        return 127

UNRESOLVED_RE = re.compile(r"\$\{[^}]+\}")

def expand_env_mapping(env_map: dict[str, str]) -> tuple[list[str], list[str]]:
    """Returns (env_flags_for_codex, unresolved_keys)"""
    flags = []
    unresolved = []
    for k, v in (env_map or {}).items():
        expanded = os.path.expandvars(v)
        if UNRESOLVED_RE.search(expanded):
            unresolved.append(k)
        flags.extend(["--env", f"{k}={expanded}"])
    return flags, unresolved

def main():
    ap = argparse.ArgumentParser(
        description="Register an MCP server with Claude and Codex from an atomic JSON file."
    )
    ap.add_argument("json_file", help="Path to atomic MCP JSON (single server object).")
    ap.add_argument("--name", help="Explicit server name (defaults to filename sans .json).")
    ap.add_argument("--skip-claude", action="store_true", help="Skip Claude registration.")
    ap.add_argument("--skip-codex", action="store_true", help="Skip Codex registration.")
    ap.add_argument("--dry-run", action="store_true", help="Print commands without executing.")
    args = ap.parse_args()

    path = args.json_file
    if not os.path.isfile(path):
        print(f"ERROR: file not found: {path}", file=sys.stderr)
        sys.exit(1)

    with open(path, "r", encoding="utf-8") as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError as e:
            print(f"ERROR: invalid JSON: {e}", file=sys.stderr)
            sys.exit(1)

    name = args.name or os.path.splitext(os.path.basename(path))[0]
    cmd = data.get("command", "")
    arg_list = data.get("args", []) or []
    env_map = data.get("env", {}) or {}

    # Validate minimum fields
    if not isinstance(arg_list, list):
        print("ERROR: 'args' must be a JSON array.", file=sys.stderr); sys.exit(1)
    if not isinstance(env_map, dict):
        print("ERROR: 'env' must be a JSON object.", file=sys.stderr); sys.exit(1)

    # Prepare JSON payload for Claude (compact)
    compact_json = json.dumps(data, separators=(",", ":"))

    # Prepare env flags for Codex (after expansion)
    env_flags, unresolved = expand_env_mapping(env_map)
    if unresolved:
        print("⚠️  Unresolved env substitutions for keys:", ", ".join(unresolved))

    # Claude
    if not args.skip_claude:
        if not which("claude"):
            print("ERROR: 'claude' CLI not found. Install or use --skip-claude.", file=sys.stderr)
            sys.exit(127)
        print(f"\nRegistering '{name}' with Claude…")
        rc = run(["claude", "mcp", "add-json", name, compact_json], args.dry_run)
        if rc != 0:
            print(f"⚠️  Claude returned non-zero exit code ({rc}). Continuing to Codex…", file=sys.stderr)
        else:
            print("✓ Claude: added.")

    # Codex
    if not args.skip_codex:
        if not cmd:
            print("ℹ️  No 'command' in JSON; skipping Codex.", file=sys.stderr)
        else:
            if not which("codex"):
                print("ERROR: 'codex' CLI not found. Install or use --skip-codex.", file=sys.stderr)
                sys.exit(127)
            print(f"\nRegistering '{name}' with Codex…")
            full = ["codex", "mcp", "add", name] + env_flags + ["--", cmd] + arg_list
            rc = run(full, args.dry_run)
            if rc != 0:
                sys.exit(rc)
            print("✓ Codex: added.")

if __name__ == "__main__":
    main()
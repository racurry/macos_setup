#!/usr/bin/env bash
set -euo pipefail

# --- Config / constants -------------------------------------------------------
BRCTL="/System/Library/PrivateFrameworks/CloudDocs.framework/Versions/A/Resources/brctl"
ICLOUD_ROOT="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
TMPDIR="$(mktemp -d -t iclouddiag)"
STATUS_OUT="$TMPDIR/status.txt"
LOG_OUT="$TMPDIR/log.txt"

cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

# --- Helpers ------------------------------------------------------------------
say() { printf "\n%s\n" "$*"; }
section() { printf "\n\033[1m%s\033[0m\n" "$*"; }
exists() { command -v "$1" >/dev/null 2>&1; }

# --- Preflight ----------------------------------------------------------------
section "iCloud Drive Diagnostic"
echo "Time: $(date)"
echo "macOS: $(sw_vers 2>/dev/null | tr '\n' ' ' | sed 's/  / /g')"
echo "iCloud Drive root: $ICLOUD_ROOT"

if [[ ! -x "$BRCTL" ]]; then
  echo "ERROR: brctl not found at $BRCTL (macOS CloudDocs tool)."
  echo "This script expects macOS with iCloud Drive enabled."
fi

if [[ ! -d "$ICLOUD_ROOT" ]]; then
  echo "WARNING: iCloud Drive root not found. If you just enabled iCloud Drive, try again after it initializes."
fi

# --- Process / service status -------------------------------------------------
section "Processes (should see 'bird' and 'cloudd')"
pgrep -lf 'bird|cloudd' || echo "No iCloud sync processes found (they will auto-launch if iCloud Drive is enabled)."

# --- brctl status -------------------------------------------------------------
if [[ -x "$BRCTL" ]]; then
  section "CloudDocs status (raw)"
  "$BRCTL" status 2>&1 | tee "$STATUS_OUT" | tail -n 40

  section "Quick counters from status"
  # Heuristic counters; brctl output varies across macOS versions. We grep common states.
  {
    echo -n "Uploading:   "; grep -Ei 'upload(ing| pending)?' "$STATUS_OUT" | wc -l | awk '{print $1}'
    echo -n "Downloading: "; grep -Ei 'download(ing| pending)?' "$STATUS_OUT" | wc -l | awk '{print $1}'
    echo -n "Conflicts:   "; grep -Ei 'conflict' "$STATUS_OUT" | wc -l | awk '{print $1}'
    echo -n "Errors:      "; grep -Ei 'error|failed|denied|forbidden|nospace|quota' "$STATUS_OUT" | wc -l | awk '{print $1}'
    echo -n "Evicted:     "; grep -Ei 'evict(ed)?' "$STATUS_OUT" | wc -l | awk '{print $1}'
    echo -n "Waiting:     "; grep -Ei 'waiting|queued|pending' "$STATUS_OUT" | wc -l | awk '{print $1}'
  } | column -t
fi

# --- Recent error-ish log lines ----------------------------------------------
if [[ -x "$BRCTL" ]]; then
  section "Recent CloudDocs log (last ~500 lines, error-filtered)"
  "$BRCTL" log --shorten 2>&1 | tail -n 500 > "$LOG_OUT" || true
  grep -Ei 'error|fail|denied|forbidden|quota|nospace|timeout|unreachable|auth' "$LOG_OUT" \
    | sed 's/^/• /' \
    || echo "No obvious errors in recent brctl log."
fi

# --- Locate likely-problem files ---------------------------------------------
section "Likely-problem files (from logs/status)"
# Collect paths that look like file refs from status/log
awk '
  match($0, /\/Users\/[^ ]*\/Library\/Mobile Documents\/com~apple~CloudDocs\/[^ ]+/, m) { print m[0] }
' "$STATUS_OUT" "$LOG_OUT" 2>/dev/null \
| sed 's/\\ / /g' \
| sed 's/^.*com~apple~CloudDocs\///' \
| sed "s|^|$ICLOUD_ROOT/|" \
| sort -u \
| while IFS= read -r p; do
    [[ -e "$p" ]] && echo "• $p"
  done \
| sed 's/^/  /' \
|| echo "No file paths surfaced by brctl to inspect."

# --- Filename/path sanity checks ---------------------------------------------
section "Filename / path sanity checks (common iCloud gotchas)"

if [[ -d "$ICLOUD_ROOT" ]]; then
  say "• Very long names (> 200 chars):"
  find "$ICLOUD_ROOT" -type f -print0 2>/dev/null \
    | while IFS= read -r -d '' f; do
        base="$(basename "$f")"
        [[ ${#base} -gt 200 ]] && echo "  • $f"
      done \
    || true

  say "• Suspicious temp/cache artifacts:"
  find "$ICLOUD_ROOT" -type f \( -name ".*.tmp" -o -name "*.tmp" -o -name "~*" -o -name "*.partial*" -o -name "*.crdownload" \) -print \
    | sed 's/^/  • /' \
    || true

  say "• Huge files (> 15 GB) that can stall uploads:"
  find "$ICLOUD_ROOT" -type f -size +15G -print 2>/dev/null | sed 's/^/  • /' || true

  say "• Files not yet downloaded locally (*.icloud stubs):"
  find "$ICLOUD_ROOT" -type f -name "*.icloud" -print 2>/dev/null | sed 's/^/  • /' || true
else
  echo "Skip: iCloud root not found."
fi

# --- Permissions sanity (problem folders) ------------------------------------
section "Permissions sanity (drwx for folders; look for odd owners)"
if [[ -d "$ICLOUD_ROOT" ]]; then
  # Show top-level with owners/permissions (quick scan)
  ls -lO@ "$ICLOUD_ROOT" | sed 's/^/  /'
fi

# --- Gentle restart suggestions ----------------------------------------------
section "If things look stuck (safe actions)"
cat <<'EOF'
1) Restart iCloud agents (safe):
   killall bird cloudd 2>/dev/null; sleep 2; open -R "$HOME/Library/Mobile Documents/com~apple~CloudDocs"

2) Nudge a stuck item:
   - Move the problem file/folder OUT of iCloud Drive (e.g., to Desktop), wait 10–20s, then move it back.

3) Check space:
   - Ensure both local disk and iCloud storage have free space.

4) Rename suspicious files:
   - Shorten extremely long names; remove trailing spaces or odd symbols.

(Do NOT delete ~/Library/Mobile Documents or CloudDocs caches unless you have a full backup.)
EOF

section "Done"
echo "Temp files: $TMPDIR (will be removed on exit)"

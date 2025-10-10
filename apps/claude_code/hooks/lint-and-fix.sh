#!/bin/bash

# Read the JSON input from stdin
JSON_INPUT=$(cat)

# Extract the file path from the JSON
FILE_PATH=$(echo "$JSON_INPUT" | jq -r '.tool_input.file_path // empty')

# Check if file path exists and is a markdown file
if [[ -n "$FILE_PATH" ]] && ([[ "$FILE_PATH" == *.md ]] || [[ "$FILE_PATH" == *.markdown ]]); then
    # Capture markdownlint output and exit code
    LINT_OUTPUT=$(mdlint --fix "$FILE_PATH" 2>&1)
    LINT_EXIT_CODE=$?

    if [[ $LINT_EXIT_CODE -eq 0 ]]; then
        # Success - file was clean or fixed
        CONTEXT="✅ Markdown formatting fixed: $(basename "$FILE_PATH")"
    else
        # Failure - show the actual linting errors only
        ISSUES=$(echo "$LINT_OUTPUT" | grep -E "MD[0-9]+" | sed 's/^/   /')

        # Still try to fix what we can
        markdownlint --fix "$FILE_PATH" 2>/dev/null || true

        CONTEXT="⚠️  Markdownlint issues in $(basename "$FILE_PATH"):\n${ISSUES}\n   Attempted auto-fix where possible."
    fi

    # Output JSON in the correct format for Claude Code hooks
    jq -n --arg context "$CONTEXT" '{
        hookSpecificOutput: {
            hookEventName: "PostToolUse",
            additionalContext: $context
        }
    }'
fi

# Always exit 0 to not block Claude's workflow
exit 0

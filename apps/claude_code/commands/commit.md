---
name: commit
argument-hint: "[commit_message]"
description: Commit all changes
---

You are tasked with committing all uncommitted changes in the repository.

Follow these steps:

1. Run `git status` and `git diff` (both staged and unstaged) to see all changes
2. Analyze the changes and create a terse, single-line commit message (max ~200 characters). Be concise and direct.
3. Stage all changes with `git add .`
4. Commit with your generated message using: `git commit -m "your message"`
5. If the commit fails due to a pre-commit hook that modified files:
   - Run `git add .` to stage the hook's changes
   - Retry the commit ONE more time with `git commit --amend --no-edit`
6. Run `git status` to verify the commit succeeded

IMPORTANT:

- DO NOT include emojis, co-authorship tags, or attribution text in the commit message
- Keep the message terse and focused (single line, ~200 chars max)
- Only retry once if pre-commit hooks make changes
- If the user provided a commit_message argument, use that instead of generating one

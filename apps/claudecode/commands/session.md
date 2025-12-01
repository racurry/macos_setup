---
description: Show current session state (model, cost, duration, git branch)
---

Display the current session information by running these commands and formatting the output:

1. **Git info** (if in a repo):

   ```bash
   git rev-parse --is-inside-work-tree 2>/dev/null && git symbolic-ref --short HEAD 2>/dev/null
   ```

2. **Basic environment**:

   ```bash
   pwd
   ```

3. **Format a summary** showing:
   - Current model (from your context)
   - Session cost (from your context, if available)
   - Session duration (from your context, if available)
   - Working directory
   - Git branch (if in a repo)
   - Any other session context you have access to

Present as a clean, scannable summary - not verbose. Example format:

```text
Session Info
------------
Model:    Claude Opus 4
Cost:     $0.0234
Duration: 12m
Directory: ~/workspace/my-project
Branch:   feature/new-thing
```

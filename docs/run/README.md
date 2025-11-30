# Run Scripts

Scripts in `run/` are top-level orchestration and maintenance commands.

## When to Add Here

Add a script to `run/` when it:

- Orchestrates multiple app scripts or system-wide operations
- Provides repository-level utilities (testing, maintenance, setup)
- Doesn't belong to a specific app

For app-specific scripts, use [`apps/{appname}/`](../apps/README.md) instead.

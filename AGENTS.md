# AGENTS.md

Hey, agents!  This file contains important guidelines and rules for working with the code in this repository.  Please read it carefully and follow the instructions below.

## Project Overview

This is a collection of scripts and tools to enable the user to use consistent and standardized tooling across multiple macOS systems.  It includes a single automated setup script, as well as helper scripts, settings, and utilities.

## TOP RULES

When renaming or moving files:

- ALWAYS search the codebase for references to those files and update them accordingly
- ALWAYS run @tests/run.sh after changes to verify nothing broke

When writing scripts:

- ALWAYS choose the most appropriate language (e.g., write Python directly instead of bash that generates Python)
- ALWAYS include a --help flag that describes purpose and usage
- ALWAYS use consistent flag formats:
  - Help flag: `-h|--help` (both short and long forms)
  - Boolean flags: `--flag-name` (long form only, use hyphens not underscores)
  - Positional arguments for main parameters (e.g., parent directory, file path)

When writing tests:

- ALWAYS run tests immediately after creating them to verify they pass
- ALWAYS test end-to-end workflows that users depend on, not isolated implementation details
- ALWAYS ensure a test failure indicates something meaningful is broken
- NEVER write tests that only verify current implementation (e.g., testing exact log formats, internal variable names)
- NEVER use mocking; write lightweight smoke tests only

## Key Commands

```bash
# Run the complete setup process (idempotent)
./setup.sh

# Run all tests
./tests/run.sh

# Run a specific script
./scripts/bash/{script_name}.sh
```

## Core Structure

- **bin/**: Standalone binaries
- **lib/**: Common libraries, separated by language (/bash/, /python/)
- **scripts/**: Individual scripts, separated by language (/bash/, /python/)
- **dotfiles/**: Configuration files symlinked to home directory
- **docs/**: Documentation and manual checklists
- **tests/**: Tests

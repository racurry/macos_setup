# AGENTS.md

Hey, agents!  This file contains important guidelines and rules for working with the code in this repository.  Please read it carefully and follow the instructions below.

## Project Overview

This is a collection of scripts and tools to enable the user to use consistent and standardized tooling across multiple macOS systems.  It includes a single automated setup script, as well as helper scripts, settings, and utilities.

## TOP RULES

When renaming or moving files:

- ALWAYS search the codebase for references to those files and update them accordingly
- ALWAYS run ./test.sh after changes to verify nothing broke

When writing scripts:

- ALWAYS choose the most appropriate language for the task:
  - Bash: System operations, file manipulation, orchestration, calling other tools
  - Python: Data processing, JSON/API work, complex logic, text manipulation
  - JavaScript/Node: npm ecosystem tools, frontend-related tasks
  - Ruby: gem ecosystem tools, text processing
  - Write the logic directly in the target language instead of generating code (e.g., write Python directly instead of bash that generates Python)
- ALWAYS include a --help flag that describes purpose and usage
- ALWAYS use consistent flag formats:
  - Help flag: `-h|--help` (both short and long forms)
  - Boolean flags: `--flag-name` (long form only, use hyphens not underscores)
  - Positional arguments for main parameters (e.g., parent directory, file path)
- App-specific scripts can be any language but should be named appropriately:
  - Bash: `apps/{appname}/{appname}.sh`
  - Python: `apps/{appname}/{appname}.py`
  - JavaScript: `apps/{appname}/{appname}.js`
  - Ruby: `apps/{appname}/{appname}.rb`
- Bash scripts should source lib/bash/common.sh for shared utilities
- Non-bash scripts should be executable with appropriate shebang (#!/usr/bin/env python3, etc.)

When writing tests:

- ALWAYS run tests immediately after creating them to verify they pass
- ALWAYS test end-to-end workflows that users depend on, not isolated implementation details
- ALWAYS ensure a test failure indicates something meaningful is broken
- NEVER write tests that only verify current implementation (e.g., testing exact log formats, internal variable names)
- NEVER use mocking; write lightweight smoke tests only
- Tests should be co-located with the code they test (e.g., apps/brew/test_brew.bats)
- Tests should load lib/bash/common_test_helper.bash using relative paths

## Key Commands

```bash
# Run the complete setup process (idempotent)
./setup.sh

# Run all tests (lint + unit)
./test.sh

# Run only linting
./test.sh lint

# Run only unit tests
./test.sh unit

# Run tests for a specific app only
./test.sh --app {appname}           # Lint + test specific app
./test.sh lint --app {appname}      # Lint only specific app
./test.sh unit --app {appname}      # Test only specific app

# Run a specific app script
./apps/{appname}/{appname}.sh          # Or .py, .js, .rb depending on language
```

## Core Structure

- **apps/**: Application-specific scripts, configs, and tests
  - Each app has its own directory: `apps/{appname}/`
  - Main script: `apps/{appname}/{appname}.{ext}` (use appropriate language: .sh, .py, .js, .rb)
  - Tests: `apps/{appname}/test_{appname}.bats`
  - Configs: co-located with the app
  - README: `apps/{appname}/README.md` (required)
- **bin/**: Standalone CLI utilities (on PATH)
- **lib/**: Common libraries and test helpers
  - **lib/bash/**: Bash utilities (common.sh, paths.sh, common_test_helper.bash)
  - **lib/test_common.bats**: Tests for lib/bash/common.sh
- **scripts/**: App-agnostic utility scripts
  - Scripts that don't belong to a specific app
  - Example: mvp_system_reqs_check.sh
- **docs/**: Documentation and manual checklists
- **setup.sh**: Root orchestrator that calls app scripts in order
- **test.sh**: Unified test runner (lint + unit tests)
  - Supports `--app {appname}` flag to target specific apps

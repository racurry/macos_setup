# AGENTS.md

Hey, agents!  This file contains important guidelines and rules for working with the code in this repository.  Please read it carefully and follow the instructions below.

## Project Overview

This is a collection of scripts and tools to enable the user to use consistent and standardized tooling across multiple macOS systems.  It includes a single automated setup script, as well as helper scripts, settings, and utilities.

## TOP RULES

When renaming or moving files:

- ALWAYS search the codebases for references to those files and update them accordingly.
- ALWAYS ensure that @tests/run.sh continues to pass

When writing scripts

- ALWAYS choose a language that offers the most utility; eg, a bash script that just generates python code should just be python.
- ALWAYS include a "help" option that describes the script's purpose and usage.

When writing tests:

- ALWAYS make sure tests are actually testing something useful
- NEVER use mocking; our tests are lightweight smoke tests

## Key Commands

```bash
# Run the complete setup process (idempotent)
./setup.sh

# Run all tests
./tests/run.sh
```

### Manual Execution of Individual Scripts

```bash
# Test individual setup steps
./scripts/bash/preflight.sh
./scripts/bash/brew_bundle.sh
# ... etc for any script in scripts/bash/
```

## Core Structure

- **bin/**: Standalone binaries
- **lib/**: Common libraries, separated by language (/bash/, /python/)
- **scripts/**: Individual scripts, separated by language (/bash/, /python/)
- **dotfiles/**: Configuration files symlinked to home directory
- **docs/**: Documentation and manual checklists
- **tests/**: Tests

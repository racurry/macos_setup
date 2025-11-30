# Adding New Apps

This guide describes how to add a new app to the repository.

## Directory Structure

Create a new directory under `apps/`:

```text
apps/{app}/
├── {app}.sh           # Main setup script (required).
├── README.md          # Documentation (required)
├── test_{app}.bats    # BATS unit tests (if applicable)
└── ...                # Config files, templates, etc.
```

## Apps Files

- `{app}.sh`: See [bash_scripting.md](bash_scripting.md) for bash script template and conventions.
- `test_{app}.bats`: See [testing.md](../testing.md) for BATS test templates and patterns.

### README: `README.md`

````markdown
# App Name

> ⚠️ Requires Homebrew (if applicable)

Brief description of what this app does.  [Link to official site or documentation](some_url).

## Setup

```bash
./apps/appname/appname.sh setup
```

## Files

- `config.yaml` - Configuration file
- Other files...

## Notes

Any additional notes, manual steps, or context.
````

## Checklist

When adding a new app:

- [ ] Create `apps/{app}/` directory
- [ ] Create `{app}.sh` with setup command based on [bash_scripting.md](bash_scripting.md)
- [ ] Create `README.md` with contents and setup instructions
- [ ] Create `test_{app}.bats` with basic tests _if applicable_, based on [testing.md](../testing.md)
- [ ] Verify `./test.sh lint` passes (ShellCheck)
- [ ] Verify `./test.sh --app {app}` passes (if tests exist)

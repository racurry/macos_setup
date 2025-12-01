<!-- App README Template
     Use this template when creating apps/{appname}/README.md files.
     Delete sections that don't apply. -->

# App Name

Brief description of what this app does. [Link to official docs](url).

## Setup

<!-- If setup can be automated -->

```bash
./apps/{appname}/{appname}.sh setup
```

<!-- If setup is manual -->

- [ ] Manual setup step 1
- [ ] Manual setup step 2

## Configuration

### Config File Location

- **Path**: `~/.config/{app}/config.yaml` (or wherever)
- **Format**: YAML/JSON/TOML/etc.
- **XDG Compliant**: Yes/No

### Environment Variables

| Variable | Purpose |
|----------|---------|
| `APP_CONFIG` | Override config path |

## Files

- `config.yaml` - Main configuration file
- `templates/` - Template files (if any)

## Installation Details

**Homebrew:**

```bash
brew install {app}
```

## Sync Strategy

| File | Method | Notes |
|------|--------|-------|
| `config.yaml` | Git | User preferences |
| `credentials.json` | iCloud | Contains API keys (not safe for public repo) |

<!-- Method options:
- Git: Default for portable, non-sensitive configs
- iCloud/Dropbox: Real-time sync needed OR contains private data unsafe for public repos
- Manual export: No config files, only GUI export (document steps below)
-->

**Manual import/export** (if no config files, store exports in cloud drive):

- Export: {App} > File > Export Settings
- Import: {App} > File > Import Settings

**Manual setup steps** (non-automatable):

- Grant accessibility access: System Settings > Privacy > Accessibility
- Sign in / activate license

## Maintenance

| Task | Command | Frequency |
|------|---------|-----------|
| Update | `brew upgrade {app}` | Weekly |
| Cleanup | `{app} cleanup` | Monthly |
| Health check | `{app} doctor` | As needed |

## Notes

Any manual steps, caveats, or important context.

## References

- [Official Documentation](url)
- [GitHub Repository](url)

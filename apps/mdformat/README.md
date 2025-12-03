# mdformat

CommonMark-compliant Markdown formatter. Automatically reformats Markdown files for consistent style, with special support for GitHub Flavored Markdown tables.

## Installation

```bash
uv tool install mdformat --with mdformat-gfm --with mdformat-frontmatter
```

Why `uv tool install` instead of Homebrew? The brew formula does not include plugins. The `--with` flags install mdformat-gfm (tables, strikethrough, etc.) and mdformat-frontmatter (YAML front matter) alongside the base tool.

## Setup

```bash
./apps/mdformat/mdformat.sh setup
```

This symlinks `.mdformat.toml` to your home directory.

## How It Differs from markdownlint

| Tool | Purpose | Action |
|------|---------|--------|
| **mdformat** | Formatter | Rewrites files to enforce style |
| **markdownlint** | Linter | Reports violations without changing files |

Use both together: mdformat handles formatting (especially tables), markdownlint catches semantic issues.

**Run order matters:** Always run mdformat before markdownlint.

```bash
mdformat file.md && markdownlint-cli2 --fix file.md
```

mdformat is opinionated and will strip certain constructs that markdownlint --fix adds (e.g., angle brackets around URLs). Running markdownlint second ensures its fixes persist.

## Configuration

Active settings in `.mdformat.toml`:

| Option | Value | Why |
|--------|-------|-----|
| `wrap` | `"keep"` | Preserves semantic line breaks; no reflowing of prose |
| `end_of_line` | `"lf"` | Unix line endings for cross-platform consistency |

See `.mdformat.toml` for all available options with documentation.

## Usage

```bash
# Format a file
mdformat README.md

# Format all markdown in a directory
mdformat docs/

# Check without modifying (exit 1 if changes needed)
mdformat --check README.md
```

## Syncing Preferences

Repo sync. Config symlinked to `~/.mdformat.toml`.

## References

- [mdformat Documentation](https://mdformat.readthedocs.io/en/stable/)
- [Configuration File](https://mdformat.readthedocs.io/en/stable/users/configuration_file.html)
- [Available Plugins](https://mdformat.readthedocs.io/en/stable/users/plugins.html)

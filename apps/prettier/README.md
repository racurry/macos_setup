# Prettier

Opinionated code formatter for JavaScript, TypeScript, CSS, HTML, JSON, Markdown, and more.

## Installation

```bash
brew install prettier
```

## Setup

```bash
./apps/prettier/prettier.sh setup
```

This symlinks:

- `.prettierrc.json5` to `~/.prettierrc.json5` (global config)
- `.prettierignore` to `~/.prettierignore` (global ignore patterns)

## Configuration

The config file (`.prettierrc.json5`) uses JSON5 format to support comments.

Active settings (differs from defaults):

| Option | Value | Why |
|--------|-------|-----|
| `printWidth` | 100 | Wider than 80 to reduce wrapping; still fits split-screen |
| `singleQuote` | true | JS community standard; less noisy than double quotes |
| `singleAttributePerLine` | true | Cleaner diffs for JSX/HTML with multiple attributes |

All other options use Prettier defaults. See `.prettierrc.json5` for exhaustive documentation of every option.

## Project-Level Config

For project-specific settings, copy the config to your project root:

```bash
cp ~/.prettierrc.json5 /path/to/project/.prettierrc.json5
```

Project configs take precedence over the global config.

## Ignore Patterns

The `.prettierignore` file excludes common directories and files:

- Build outputs (`dist/`, `build/`, `.next/`)
- Dependencies (`node_modules/`)
- Lock files (`package-lock.json`, `yarn.lock`)
- Generated files (`*.generated.*`, `*.min.js`)

Copy to project roots and customize as needed.

## Syncing Preferences

Repo sync. Config symlinked to `~/.prettierrc.json5`.

## References

- [Prettier Options](https://prettier.io/docs/options)
- [Configuration File](https://prettier.io/docs/configuration)
- [Prettier Rationale](https://prettier.io/docs/rationale) - Why Prettier makes certain choices

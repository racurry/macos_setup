# ESLint

JavaScript and TypeScript linter with pluggable rules.

## Installation

```bash
brew install eslint
```

## Setup

No global configuration. ESLint is configured per-project by design.

To start a new project with ESLint:

```bash
npm init @eslint/config@latest
```

Or copy the template from this directory:

```bash
cp apps/eslint/eslint.config.js /path/to/project/
```

## Configuration

ESLint v9+ uses the "flat config" format (`eslint.config.js`). The legacy `.eslintrc.*` format is deprecated and will be removed in v10.

The template in this directory provides a sensible starting point for TypeScript projects using:

- `@eslint/js` recommended rules
- `typescript-eslint` recommended rules
- Prettier compatibility (disables conflicting rules)

Customize the template for your project's needs.

## Syncing Preferences

Not supported. ESLint does not support global configuration - each project must have its own `eslint.config.js`.

## References

- [ESLint Getting Started](https://eslint.org/docs/latest/use/getting-started)
- [Configuration Files](https://eslint.org/docs/latest/use/configure/configuration-files)
- [typescript-eslint](https://typescript-eslint.io/getting-started/)
- [Configuration Migration Guide](https://eslint.org/docs/latest/use/configure/migration-guide) (eslintrc to flat config)

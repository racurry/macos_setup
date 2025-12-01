# shfmt

> Installed via Homebrew

Shell script formatter. Uses EditorConfig for configuration.

## Setup

```bash
./apps/shfmt/shfmt.sh setup
```

## Files

- `.editorconfig` - EditorConfig file symlinked to `~/.editorconfig`

## Notes

shfmt reads `.editorconfig` files automatically. The config sets:

- 4-space indentation for shell scripts
- LF line endings
- UTF-8 charset
- Final newline

This `.editorconfig` is symlinked to `~/.editorconfig` so it applies globally
as a fallback. Project-level `.editorconfig` files will override these settings.

# Rules for Coding Agents

- **Runtime management**: Use `asdf` for runtime version management (never install runtimes via apt/brew/etc).  If asdf is not installed, ask for guidance.
- **Project environment**: Use `direnv` to manage project environments (venvs, PATH, env vars, etc.). Create `.envrc` if needed. If direnv is not installed, ask for guidance.
- **Package management**: For asdf-managed runtimes (node/python/ruby/etc), install packages locally to the project; never install globally
- **Web searches**: Verify current date/year in search queries when searching for recent documentation or time-sensitive information
- **Git commands**: Use `git` directly, not `git -C /path` - the working directory is already the repo root
- **Default license**: NEVER include license information in generated code unless explicitly requested by the user
- **Author attribution**: NEVER include author attribution in generated code unless explicitly requested by the user

## Python rules

- **Virtual environments**: Use `venv` for virtual environments. Configure `.envrc` with `layout python` to integrate with direnv.
- **Package management**: Use `uv` for package management, unless the project already uses other tools (poetry, pipenv, conda, etc.). Check for existing configuration files (pyproject.toml, Pipfile, environment.yml) before making assumptions.

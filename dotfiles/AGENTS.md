# Rules for Coding Agents

- **Runtime management**: Use `asdf` for runtime version management (never install runtimes via apt/brew/etc)
- **Package management**: For asdf-managed runtimes (node/python/ruby/etc), install packages locally to the project; never install globally
- **Running code**: Execute commands from git repository root using relative paths (e.g., `./script.sh`, not `/Users/username/dir1/project/script.sh`); NEVER cd into subdirectories to run code
- **Web searches**: Verify current date/year in search queries when searching for recent documentation or time-sensitive information
- **Talking to github**:prefer `gh`.  If `gh` is unavailable or its feature set doesn't support the use cause, fallback to MCP when available.

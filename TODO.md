
# TODO

Stuff to add to this setup

## Agent workflow

For any todo in `Ready to work`,  For every todo, use a sub-agent.  Each agent should read the entire codebase to fully understand the context of the todo.  If it is
  clear what the problem and solution is, use `gh` to open an issue in <https://github.com/racurry/motherbox> using gh.  Add enough
  detail of the problem, solution, and actions to take in the issue so that an AI agent can implement the solution.
  \
  If it is not clear, the subagent should return to the main agent a list of clarifying questions.  The main agent should add sub
  bullets asking the clarifying questions.

## Ready

- [ ] Add all VS Code user settings to apps/vscode, create script to sync/symlink as needed
  - **Clarifying questions needed:**
    1. Where are the VS Code user settings currently located? Are they at the standard location (`~/Library/Application Support/Code/User/settings.json`), already synced somewhere, or should we copy them from a specific machine?
    2. What should the sync/symlink strategy be? Should VS Code settings be symlinked (like apps/asdf/.tool-versions), copied (like MailMate keybindings), or something else?
    3. Which VS Code settings files should be tracked? Just `settings.json` and `keybindings.json`? Also `snippets/`, `tasks.json`, `launch.json`? Should machine-specific settings be excluded?
    4. Should this script be integrated into the main run/setup.sh workflow or remain manual?
    5. Should VS Code settings have work/personal variants (using SETUP_MODE)?
- [ ] Add a github action to periodically check for the latest asdf runtimes
- [ ] Fix the sudo check - i actually want to just do it once for setup
- [ ] Add default opinionated configs for all linters
- [ ] Get mcp logic set up for gemini, codex

## Icebox

- [ ] Split the Brewfile up - Allow brew to install mas, and then have another script check for mas before calling mas install against the Brewfile.
- [ ] Think about update strategies for installed apps
- [ ] Can I make more complex settings with an applescript?
- [ ] Audit my system settings and see what I can automate
- [ ] Pull claude code settings out into a standalone repo; this repo will need to pull that repo down and set it up

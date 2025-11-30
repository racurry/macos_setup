
# TODO

Stuff to add to this setup

## Agent workflow

For any todo in `Ready to work`,  For every todo, use a sub-agent.  Each agent should read the entire codebase to fully understand the context of the todo.  If it is
  clear what the problem and solution is, use `gh` to open an issue in <https://github.com/racurry/macos_setup> using gh.  Add enough
  detail of the problem, solution, and actions to take in the issue so that an AI agent can implement the solution.
  \
  If it is not clear, the subagent should return to the main agent a list of clarifying questions.  The main agent should add sub
  bullets asking the clarifying questions.

## Ready

- [ ] Bug: When running setup.sh on a system that doesn't already have brew installed, the whole set up fails.  It tries to run brew bundle referencing files in ~. before it calls `dotfiles.sh`.
- [ ] Add all VS Code user settings to apps/vscode, create script to sync/symlink as needed
  - **Clarifying questions needed:**
    1. Where are the VS Code user settings currently located? Are they at the standard location (`~/Library/Application Support/Code/User/settings.json`), already synced somewhere, or should we copy them from a specific machine?
    2. What should the sync/symlink strategy be? Should VS Code settings be symlinked (like apps/asdf/.tool-versions), copied (like MailMate keybindings), or something else?
    3. Which VS Code settings files should be tracked? Just `settings.json` and `keybindings.json`? Also `snippets/`, `tasks.json`, `launch.json`? Should machine-specific settings be excluded?
    4. Should this script be integrated into the main setup.sh workflow or remain manual?
    5. Should VS Code settings have work/personal variants (using SETUP_MODE)?
- [ ] create a computer specific config file for this repo that lives in ~/.everythingscomputer. Everything should be moved in there that is mutable. For example, backup files, home versus work setting, etc.
- [ ] Figure out a way for the claudecode.sh script to merge apps/claudecode/settings.json into ~/.claude/settings.json
- [ ] Overhaul mcp - just create a .mcp.json in ~/ that has my servers in it.  Remove the mcp stuff from this repo.
- [ ] Auto-update/generate @docs/README.md and @docs/dev_tools.md.
- [ ] Add a github action to periodically check for the latest asdf runtimes

## Icebox

- [ ] How do I get things updated to simplify for real life?  Eg getting 1password set up unlocks a lot as I can easily login to app store & github
- [ ] Figure out how to get the install to run without having to do git clone first.  Maybe a curl pipe to bash that does the git clone and then runs setup.sh?
- [ ] Split the Brewfile up - Allow brew to install mas, and then have another script check for mas before calling mas install against the Brewfile.
- [ ] Think about update strategies for installed apps
- [ ] How do we clean up old dotfiles backups?
- [ ] should i move my helper scripts in here?
- [ ] Can I make more complex settings with an applescript?
- [ ] Audit my system settings and see what I can automate
- [ ] Pull claude code settings out into a standalone repo; this repo will need to pull that repo down and set it up

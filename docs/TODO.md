
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

- [ ] Update @scipts/python/audit_apps.py to write to ./tmp instead of /docs.  Add ./tmp to .gitignore
- [ ] Update @scipts/python/audit_apps.py to document currently installed VS Code extensions
- [ ] Add all VS Code user settings to apps/vscode, create script to sync/symlink as needed
- [ ] Add update command to scripts/bash/dotfiles.sh to prune ~/.dotfiles_backup entries older than 60 days
- [ ] Add update command to scripts/bash/brew.sh for brew update/upgrade/cleanup
- [ ] Add update command to scripts/bash/asdf.sh to refresh plugins and runtimes
- [ ] Add update command to scripts/bash/oh_my_zsh.sh to run omz update safely
- [ ] Add update command to scripts/bash/ssh.sh to prune ~/.ssh/backups entries older than 60 days

## Icebox

- [ ] How do I get things updated to simplify for real life?  Eg getting 1password set up unlocks a lot as I can easily login to app store & github
- [ ] Figure out how to get the install to run without having to do git clone first.  Maybe a curl pipe to bash that does the git clone and then runs setup.sh?
- [ ] Split the Brewfile up - Allow brew to install mas, and then have another script check for mas before calling mas install against the Brewfile.
- [ ] Think about update strategies for installed apps
- [ ] How do we clean up old dotfiles backups?
- [ ] should i move my helper scripts in here?
- [ ] Can I make more complex settings with an applescript?
- [ ] Audit my system settings and see what I can automate

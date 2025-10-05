
# TODO

Stuff to add to this setup

## Straightforward todos

- [ ] Add VSCode extensions to the Brewfile(s)
  - **Clarifying questions needed:**
  - Should ALL 50 currently installed extensions be added, or only a curated subset?
  - How should extensions be distributed across Brewfile/Brewfile.personal/Brewfile.work?
  - Is VSCode Settings Sync currently being used? Does this conflict with Brewfile-based extension management?
  - Which extensions are work-specific vs personal?
- [ ] Create a script for updates; brew cleanup, brew update, brew upgrade, mas upgrade, get latest asdf versions, clear old dotfiles backups
  - **Clarifying questions needed:**
  - Standalone executable in /bin/ or bash script in /scripts/bash/?
  - Should homebrew operations run on all Brewfiles or just installed packages?
  - Should mas upgrade all apps or only those in Brewfile?
  - For "get latest asdf versions": update plugins, update .tool-versions, or update to latest available versions?
  - What defines "old" dotfiles backups? (keep N most recent, keep from last X days, prompt user?)
  - Should it also clean ~/.ssh/backups/ or only ~/.dotfiles_backup/?
  - Fully automated or interactive (ask for confirmation)?
  - How to handle errors? (fail fast or continue and report at end?)
- [ ] Update @scipts/python/audit_apps.py to write to ./tmp instead of /docs.  Add ./tmp to .gitignore
- [ ] Update @scipts/python/audit_apps.py to document currently installed VS Code extensions

## Bigger picture things; needs more thought

- [ ] How do I get things updated to simplify for real life?  Eg getting 1password set up unlocks a lot as I can easily login to app store & github
- [ ] Figure out how to get the install to run without having to do git clone first.  Maybe a curl pipe to bash that does the git clone and then runs setup.sh?
- [ ] Split the Brewfile up - Allow brew to install mas, and then have another script check for mas before calling mas install against the Brewfile.
- [ ] Think about update strategies for installed apps
- [ ] How do we clean up old dotfiles backups?
- [ ] should i move my helper scripts in here?
- [ ] Can I make more more complex settings with an applescript?
- [ ] Audit my systems settings and see what I can automate

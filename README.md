# Setup a new OS X machine

## Set up a new machine

Or just update a current one.  These scripts should be idempotent.

Things that happen
1. Install a bunch of software
2. Set a bunch of settings
3. Sync up some dotfiles
4. Remind you about some manual setup steps

### Step 0: Clone this repo

1. Generate a new ssh key:
`ssh-keygen -t rsa`
2. Copy it to your clipboard:
`pbcopy < ~/.ssh/id_rsa.pub`
3. Add it here: [github settings](https://github.com/settings/keys)
4. Clone the repo:
```
mkdir ~/workspace
cd ~/workspace
git clone git@github.com:racurry/osx_setup.git
```

### Step 1: Run the setup

```
cd osx_setup
./macos_setup
```

There are some bits that require human intervention.

To force a complete re-run (ignoring previous execution tracking):

```
./macos_setup --force
```

To run system hygiene (update packages, plugins, and configurations):

```
./macos_setup --update
```

## This adds a command to your path

You can rerun the setup any time with `macoscfg`.

## System Hygiene

The `--update` flag runs a comprehensive system hygiene routine that:

- Updates the osx_setup repository
- Updates asdf plugins and checks for newer tool versions  
- Updates oh-my-zsh
- Updates Homebrew packages
- Verifies Brewfile package compliance
- Syncs app configurations
- Cleans up old packages
- Runs health checks on critical development tools

This can also be run directly with `bin/hygiene` or the `machygiene` command (available after initial setup).

## Adding new stuff

Dump it into the relevant file in `/data`.

## References

### macOS settings
- http://www.bresink.com/osx/TinkerTool.html

### Cask lists
- https://formulae.brew.sh/

## Fixes
- [ ] Actually make sure the macos settings work
- [ ] Create a generic folder action for copy path in finder

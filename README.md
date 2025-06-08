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

```bash
mkdir ~/workspace
cd ~/workspace
git clone git@github.com:racurry/osx_setup.git
```

### Step 1: Run the setup

```bash
cd osx_setup
./macos_setup
```

There are some bits that require human intervention.

To force a complete re-run (ignoring previous execution tracking):

```bash
./macos_setup --force
```

To run system hygiene (update packages, plugins, and configurations):

```bash
./macos_setup --update
```

## This adds a command to your path

You can rerun the setup any time with `macoscfg`.

## Extra stuff

```bash
    ./bin/setup_app_configs --export # Export settings from apps that don't support cloud sync
    ./bin/setup_app_configs --import # Import settings into apps that don't support cloud sync 
```

## Adding new stuff

Dump it into the relevant file in `/data`.

## References

### macOS settings

- <http://www.bresink.com/osx/TinkerTool.html>

### Cask lists

- <https://formulae.brew.sh/>

## Fixes

- [ ] Create a generic folder action for copy path in finder
- [ ] Auto install things from .tool-versions.  Install known packages, like claude code

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
`mkdir ~/workspace`
`git clone git@github.com:racurry/osx_setup.git ~/workspace`

### Step 1: Run the setup

```
cd osx_setup
./macos_setup
```

There are some bits that require human intervention.  If you want the system to just make all the decisions for you, run

`./macos_setup --unattended`

instead.

## This adds a command to your path

You can rerun the setup any time with `macoscfg`.

## macOS settings and SIP
Some of the settings in `/bin/setup_macos` need SIP turned off to actually work.  To make sure it all works,

1. Restart your Mac, holding down Command-R until you see an Apple icon and a progress bar
2. From the Utilities menu, select Terminal.
3. `csrutil disable`
4. Restart

After running, re-run the steps using `csrutil enable`

## Adding new stuffmacos_setup

Dump it into the relevant file in `/data`.

## References

### macOS settings
- http://www.bresink.com/osx/TinkerTool.html

### Cask lists
- https://formulae.brew.sh/

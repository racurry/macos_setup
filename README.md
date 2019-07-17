# Setup a new OS X machine

## Step 0: Clone this repo

1. Generate a new ssh key:
`ssh-keygen -t rsa`
2. Copy it to your clipboard:
`pbcopy < ~/.ssh/id_rsa.pub`
3. Add it here: [github settings](https://github.com/settings/keys)
4. Clone the repo:
`mkdir ~/workspace`
`git clone git@github.com:racurry/osx_setup.git ~/workspace`

## Step 1: Run the setup 

```
cd osx_setup
./setup.rb
```

## Step 2: Do a bunch of manual crap I haven't automated yet
1. Enable window switching with backtick
1. Set up a schedule for do not disturb, where it is only on from 2-2:01am
1. Configure the "today" view in notification center
1. Set spotlight search to Ctrl+_

## Step 3: Get all settings right
1. Log in to dropbox
1. `mackup restore`
1. Set up Alfred 
	1. Advanced -> preference folder to `~/Dropbox/Alfred`
	1. General -> set hotkey to cmd+space
	1. General -> request permissions

## References

### macOS settings
- http://www.bresink.com/osx/TinkerTool.html

### Cask lists
- https://formulae.brew.sh/
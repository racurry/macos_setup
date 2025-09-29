
# TODO

Stuff to add to this setup

## Straightforward todos

- [ ] Add VSCode extensions to the Brewfile(s)
- [ ] Update the manual todo list with mini-guides for all the apps
- [ ] Add output to lint.sh
- [ ] Add claude code to repo w/ a claude code gh action for PRs etc
- [ ] Make setup set a work/personal flag.  Make sure it is used for the Brewfile selection
- [ ] Update folder creator to take a parent folder location
- [ ] Consolidate 'magic' file and folder locations to one place. Should some single script just export them as env vars?
- [ ] Give every script a help option
- [ ] Give every script a "skip sudo" option

## Bigger picture things; needs more thought

- [ ] How do I get things updated to simplify for real life?  Eg getting 1password set up unlocks a lot as I can easily login to app store & github
- [ ] Figure out how to get the install to run without having to do git clone first.  Maybe a curl pipe to bash that does the git clone and then runs setup.sh?
- [ ] Split the Brewfile up - Allow brew to install mas, and then have another script check for mas before calling mas install against the Brewfile.
- [ ] Think about update strategies for installed apps
- [ ] How do we clean up old dotfiles backups?
- [ ] should i move my helper scripts in here?
- [ ] Can I make more more complex settings with an applescript?
- [ ] Audit my systems settings and see what I can automate

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh
ZSH_THEME=""

# Use the pure prompt
autoload -U promptinit; promptinit
prompt pure

HYPHEN_INSENSITIVE="true"

# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

plugins=(git bundler rake)

# ASDF
. $(brew --prefix asdf)/asdf.sh
. $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash

# The fuck
eval $(thefuck --alias)

export LANG=en_US.UTF-8
export EDITOR='vim'

# Keep less from paginating unless it needs to
export LESS="$LESS -FRXK"

# History
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=50000
HISTDUP=erase # Erase duplicates in the history file
setopt appendhistory # Append history to the history file (no overwriting)
setopt sharehistory # Share history across terminals
setopt incappendhistory # Immediately append to the history file, not just when a term is killed


# Set up NPM_TOKEN if .npmrc exists
if [ -f ~/.npmrc ]; then
  export NPM_TOKEN=`sed -n -e '/_authToken/ s/.*\= *//p' ~/.npmrc`
fi

# Help ems
export workspace=~/workspace
export inbox=~/Inbox

# Grab any stitchfix-specific aliases & configs
if [ -f ~/.stitchfixrc ]; then
  source ~/.stitchfixrc
fi

# Grab any trustworthy-specific aliases & configs
if [ -f ~/.trustworthyrc ]; then
  source ~/.trustworthyrc
fi

# Automatically ls after cd
cd () {
  builtin cd "$@";
  ls -a;
}

# Slightly more user-friendly man pages
tldr () {
  curl "cheat.sh/$1"
}

# Fiddle with that path
path+=($workspace'/helper-scripts/bin')
export PATH

# Work journaling
alias wlog="jrnl work"
alias wlconfig="subl -nw ~/.config/jrnl/jrnl.yaml"
alias wtoday="jrnl work -from today"
alias wtodayandyesterday="jrnl work -from yesterday"
alias wyesterday='jrnl work -from "yesterday 6am" -until "today 6am"'
alias wweek='jrnl work -from "last week 6am" -until "today 6am"'
alias wlweek='jrnl work -from "last monday 6am" -until "today 6am"'

# Personal journaling
alias jmonth='jrnl -from "last month" -until "today"'

# Keep friends in sync
alias friends="friends --filename '~/Dropbox/friends.md'"
alias rezsh="source ~/.zshrc"
alias zshconfig="subl -nw ~/workspace/osx_setup/data/dotfiles/.zshrc"
alias ohmyzsh="subl -nw ~/.oh-my-zsh"
alias be="bundle exec"
alias ls="ls -a"
# Fix zsh breaking rake like a total turd
alias rake='noglob bundled_rake'


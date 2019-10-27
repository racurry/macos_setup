# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

HYPHEN_INSENSITIVE="true"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"


plugins=(git bundler)

source $ZSH/oh-my-zsh.sh

# Set up some apps

eval "$(rbenv init - zsh)" # rbenv
eval $(thefuck --alias) # The fuck

# Get the path correct
export PATH=$HOME/.rbenv/bin:/usr/local/bin:$HOME/.bin:$PATH
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

# NVM!
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm

# Set up NPM_TOKEN if .npmrc exists
if [ -f ~/.npmrc ]; then
  export NPM_TOKEN=`sed -n -e '/_authToken/ s/.*\= *//p' ~/.npmrc`
fi

# Grab any work-specific aliases & configs
if [ -f ~/.workrc ]; then
  source ~/.workrc
fi

# Automatically ls after cd
cd () {
  builtin cd "$@";
  ls -a;
}

# Help ems
export workspace=~/workspace

alias rezsh="source ~/.zshrc"
alias zshconfig="subl ~/.zshrc"
alias ohmyzsh="subl ~/.oh-my-zsh"
alias be="bundle exec"
alias ls="ls -a"
# Fix zsh breaking rake like a total turd
alias rake='noglob bundled_rake'
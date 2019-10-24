# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

HYPHEN_INSENSITIVE="true"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(git bundler)

source $ZSH/oh-my-zsh.sh

# load rbenv automatically
eval "$(rbenv init - zsh)"

# Get the path correct
export PATH=$HOME/.rbenv/bin:/usr/local/bin:$HOME/.bin:$PATH
export LANG=en_US.UTF-8
export EDITOR='vim'

# NVM!
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"  # This loads nvm bash_completion

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

export workspace=~/workspace

# The Fuck
eval $(thefuck --alias)

# Aliases
alias rezsh="source ~/.zshrc"
alias zshconfig="subl ~/.zshrc"
alias ohmyzsh="subl ~/.oh-my-zsh"
alias be="bundle exec"
alias ls="ls -a"
# Fix zsh breaking rake like a total turd
alias rake='noglob bundled_rake'
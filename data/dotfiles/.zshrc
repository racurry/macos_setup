# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh
ZSH_THEME=""

HYPHEN_INSENSITIVE="true"

# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

plugins=(git bundler rake)

# Change architectures as needed
alias gointel="env /usr/bin/arch -x86_64 /bin/zsh --login"
alias goarm="env /usr/bin/arch -arm64 /bin/zsh --login"

# Work in multiple architectures
if [[ $OSTYPE == darwin* && $CPUTYPE == arm64 ]]; then
  ## Here is the ARM bit

  # Brew
  alias brew=/opt/homebrew/bin/brew


  # ASDF
  . $(brew --prefix asdf)/asdf.sh
  . $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash

  # Cocoa pods
  alias pod='arch -x86_64 pod'
else
  ## Let's go intel

  # Brew
  alias brew="arch -x86_64 /usr/local/homebrew/bin/brew"

  # ASDF
  . /usr/local/homebrew/opt/asdf/libexec/asdf.sh

  # OpenSSL
  export PATH="/usr/local/homebrew/opt/openssl@3/bin:$PATH"
fi

# Use the pure prompt
fpath+=/opt/homebrew/share/zsh/site-functions
autoload -U promptinit; promptinit
prompt pure

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
unsetopt nomatch # Don't throw an error if there are no matches, just do the right thing


# Set up NPM_TOKEN if .npmrc exists
if [ -f ~/.npmrc ]; then
  export NPM_TOKEN=`sed -n -e '/_authToken/ s/.*\= *//p' ~/.npmrc`
fi

# Help ems
export workspace=~/workspace
export inbox=~/Inbox

# Grab any galileo-specific aliases & configs
if [ -f ~/.galileorc ]; then
  source ~/.galileorc
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

# Desparately flailing at my M1 mac
# https://stackoverflow.com/questions/69012676/install-older-ruby-versions-on-a-m1-macbook
export CFLAGS="-Wno-error=implicit-function-declaration"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1) --with-readline-dir=$(brew --prefix readline)"
export LDFLAGS="-L$(brew --prefix)/opt/readline/lib"
export CPPFLAGS="-I$(brew --prefix)/opt/readline/include"
export PKG_CONFIG_PATH="$(brew --prefix)/opt/readline/lib/pkgconfig"
export optflags="-Wno-error=implicit-function-declaration"
export LDFLAGS="-L$(brew --prefix)/opt/libffi/lib"
export CPPFLAGS="-I$(brew --prefix)/opt/libffi/include"
export PKG_CONFIG_PATH="$(brew --prefix)/opt/libffi/lib/pkgconfig"

# Fiddle with that path
path+=($workspace'/helper-scripts/bin')
export PATH

alias rezsh="source ~/.zshrc"
alias zshconfig="subl -nw ~/workspace/osx_setup/data/dotfiles/.zshrc"
alias ohmyzsh="subl -nw ~/.oh-my-zsh"
alias be="bundle exec"
alias ls="ls -a"
# Fix zsh breaking rake like a total turd
alias rake='noglob bundled_rake'


# Created by `pipx` on 2022-01-18 18:51:04
export PATH="$PATH:/Users/aaron/.local/bin"



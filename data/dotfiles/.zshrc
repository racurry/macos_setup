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
if [[ "$(uname -m)" == "arm64" ]]; then
  ## Here is the ARM bit

  echo "Using arm architecture"

  # Get brew on the path
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # Brew
  alias brew=/opt/homebrew/bin/brew

  # ASDF
 . /opt/homebrew/opt/asdf/libexec/asdf.sh

else
  ## Let's go intel
  echo "Using x86 architecture"

  # Cocoa pods
  alias pod='arch -x86_64 pod'

  # Bundler
  alias bundle="arch -x86_64 bundle"

  # Brew
  eval "$(/usr/local/bin/brew shellenv)"

  # OpenSSL
  export PATH="/usr/local/homebrew/opt/openssl@3/bin:$PATH"

  # ASDF
  . /usr/local/opt/asdf/libexec/asdf.sh
fi

# Use the pure prompt
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
export workspace=~/Documents/workspace
export inbox=~/Documents/Inbox

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

findandkill() {  
  lsof -n -i:$1 | grep LISTEN | awk '{ print $2 }' | uniq | xargs kill -9
} 
alias killport=findandkill

# Homebrew (Apple Silicon) paths for libraries and headers
export PATH="/opt/homebrew/opt/bison/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/bison/lib -L/opt/homebrew/opt/openssl@3/lib -L/opt/homebrew/opt/readline/lib -L/opt/homebrew/opt/libyaml/lib -L/opt/homebrew/opt/gmp/lib"
export CPPFLAGS="-I/opt/homebrew/opt/bison/include -I/opt/homebrew/opt/openssl@3/include -I/opt/homebrew/opt/readline/include -I/opt/homebrew/opt/libyaml/include -I/opt/homebrew/opt/gmp/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/bison/lib/pkgconfig:/opt/homebrew/opt/openssl@3/lib/pkgconfig:/opt/homebrew/opt/readline/lib/pkgconfig:/opt/homebrew/opt/libyaml/lib/pkgconfig:/opt/homebrew/opt/gmp/lib/pkgconfig"

# For Ruby builds (asdf, ruby-build, etc.)
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@3)"

# Fiddle with that path
path+=($workspace'/helper-scripts/bin')
export PATH="$PATH:/Users/aaron/.local/bin"

alias rezsh="source ~/.zshrc"
alias zshconfig="subl -nw ~/workspace/osx_setup/data/dotfiles/.zshrc"
alias ohmyzsh="subl -nw ~/.oh-my-zsh"
alias ls="ls -a"

# bundler
alias be="bundle exec"

# Fix zsh breaking rake like a total turd
alias rake='noglob rake'


# ============================================================================
# OH-MY-ZSH CONFIGURATION
# ============================================================================

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh
ZSH_THEME=""

HYPHEN_INSENSITIVE="true"

# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

plugins=(git bundler rake)

# ============================================================================
# PACKAGE MANAGERS & TOOL SETUP
# ============================================================================

# Homebrew and ASDF setup
# Ensure Homebrew is on the path and asdf is sourced
# (Order matters as asdf is installed via Homebrew)
eval "$(/opt/homebrew/bin/brew shellenv)"
. $(brew --prefix asdf)/libexec/asdf.sh

# Add asdf completions
fpath=(${ASDF_DIR}/completions $fpath)

# fzf integration (if installed)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zsh-autosuggestions (if installed)
[ -f $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# ============================================================================
# SHELL APPEARANCE & BEHAVIOR
# ============================================================================

# Use the pure prompt
autoload -U promptinit; promptinit
prompt pure

# The fuck
eval $(thefuck --alias)

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR='code'

# Keep less from paginating unless it needs to
export LESS="-FRXK"

# ============================================================================
# HISTORY CONFIGURATION
# ============================================================================

HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=50000
HISTDUP=erase # Erase duplicates in the history file
setopt appendhistory # Append history to the history file (no overwriting)
setopt sharehistory # Share history across terminals
setopt incappendhistory # Immediately append to the history file, not just when a term is killed
unsetopt nomatch # Don't throw an error if there are no matches, just do the right thing

# ============================================================================
# APPLICATION-SPECIFIC SETUP
# ============================================================================

# Set up NPM_TOKEN if .npmrc exists
if [ -f ~/.npmrc ]; then
  export NPM_TOKEN=`sed -n -e '/_authToken/ s/.*\= *//p' ~/.npmrc`
fi

# ============================================================================
# DIRECTORY SHORTCUTS
# ============================================================================

export workspace=~/Documents/"950. 💻 Workspace"
export inbox=~/Documents/"000. 📥 Inbox"
export iCloud=~/iCloud
export icloud=~/iCloud  # Both cases for convenience - prevents typos

# ============================================================================
# CUSTOM FUNCTIONS
# ============================================================================

# Automatically ls after cd
cd () {
  builtin cd "$@";
  ls;
}

# Slightly more user-friendly man pages
tldr () {
  if curl -s "cheat.sh/$1" 2>/dev/null; then
    # Success - curl worked
    :
  else
    echo "Failed to fetch cheat sheet for '$1', falling back to man page..."
    man "$1"
  fi
}

# Kill process on a port
findandkill() {  
  lsof -n -i:$1 | grep LISTEN | awk '{ print $2 }' | uniq | xargs kill -9
} 
alias killport=findandkill

# ============================================================================
# PATH CONFIGURATION
# ============================================================================

# PATH modifications
export PATH="/opt/homebrew/opt/bison/bin:$PATH"  # Modern bison for parser generation
export PATH="$PATH:$workspace/helper-scripts/bin:$HOME/.local/bin"  # Personal scripts and tools

# Remove duplicates from PATH
typeset -U PATH

# ============================================================================
# ALIASES & SHORTCUTS
# ============================================================================

# Shell convenience
alias rezsh="source ~/.zshrc"
alias zshcfg="code -nw ~/workspace/osx_setup/data/dotfiles/.zshrc"
alias omzcfg="code -nw ~/.oh-my-zsh"

# macOS setup shortcuts
alias macos_setup="\"$workspace\"/osx_setup/macos_setup"

# System hygiene with automatic directory handling
machygiene() {
  (cd "$workspace/osx_setup" && bin/hygiene)
}

# Enhanced & tool overwrites
command -v bat >/dev/null 2>&1 && alias cat='bat'
if command -v eza >/dev/null 2>&1; then
  alias ls='eza -a'
  alias tree='eza --tree'
else
  alias ls="ls -aG"  # Enhanced ls: show all files and use color (fallback)
fi

# Development tools
alias be="bundle exec"  # bundler
alias rake='noglob rake'  # Fix zsh breaking rake like a total turd

# Directory navigation shortcuts
alias pd='pushd'
alias pp='popd'
alias dirs='dirs -v'

# Say the magic word
alias please='sudo $(fc -ln -1)'

# ============================================================================
# PERIODIC UPDATE CHECKING
# ============================================================================

# Check if it's time to suggest running system hygiene
_check_osx_setup_update() {
  local last_update_file="$workspace/osx_setup/data/.meta/last_hygiene_check"
  local current_time=$(date +%s)
  local update_interval=$((7 * 24 * 60 * 60))  # 7 days in seconds
  
  # Create meta directory if it doesn't exist
  mkdir -p "$(dirname "$last_update_file")" 2>/dev/null
  
  # Create file if it doesn't exist
  if [[ ! -f "$last_update_file" ]]; then
    echo "$current_time" > "$last_update_file" 2>/dev/null
    return
  fi
  
  local last_update=$(cat "$last_update_file" 2>/dev/null || echo 0)
  local time_diff=$((current_time - last_update))
  
  if (( time_diff > update_interval )); then
    echo ""
    echo "🧹 It's been a while since you ran system hygiene!"
    echo "   Run 'machygiene' to update your development environment"
    echo "   (You can disable this by setting DISABLE_OSX_SETUP_UPDATE_PROMPT=true)"
    echo ""
    echo "$current_time" > "$last_update_file" 2>/dev/null
  fi
}

# Only run the check if not disabled
if [[ -z "$DISABLE_OSX_SETUP_UPDATE_PROMPT" ]]; then
  _check_osx_setup_update
fi

# ============================================================================
# Work laptop overrides
# ============================================================================
# Grab any galileo-specific aliases & configs
if [ -f ~/.galileorc ]; then
  source ~/.galileorc
fi
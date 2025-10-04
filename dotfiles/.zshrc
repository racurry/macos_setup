# ============================================================================
# OH-MY-ZSH CONFIGURATION
# ============================================================================

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Configuration must be set before sourcing oh-my-zsh
ZSH_THEME=""
HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
plugins=()

if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  echo "Warning: Oh My Zsh is not installed at $ZSH. Prompting will be minimal."
fi

# ============================================================================
# PACKAGE MANAGERS & TOOL SETUP
# ============================================================================

# Homebrew and ASDF setup
# Ensure Homebrew is on the path and asdf is sourced
# (Order matters as asdf is installed via Homebrew)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Set Homebrew prefix for reuse throughout shell and exported for subprocesses
export BREW_PREFIX=$(brew --prefix)

. $BREW_PREFIX/opt/asdf/libexec/asdf.sh

# Add asdf completions
fpath=(${ASDF_DIR}/completions $fpath)

# Source Homebrew-installed zsh plugins
source_brew_plugin() {
  [ -f "$BREW_PREFIX/$1" ] && source "$BREW_PREFIX/$1"
}

source_brew_plugin "opt/fzf/shell/completion.zsh"
source_brew_plugin "opt/fzf/shell/key-bindings.zsh"
source_brew_plugin "share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source_brew_plugin "share/zsh-you-should-use/you-should-use.plugin.zsh"
source_brew_plugin "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"  # Must be last

unset -f source_brew_plugin

# Initialize direnv if available
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

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

# Hug the face
export HF_HOME="$HOME/.cache/huggingface"

# Secrets go in here
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

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

export workspace=~/workspace
export inbox=~/Documents/"000_Inbox"
export iCloud=~/iCloud
export icloud=~/iCloud  # Both cases for convenience - prevents typos

# ============================================================================
# CUSTOM FUNCTIONS
# ============================================================================

# Check dotfile sync status
check-dotfiles() {
  local dotfiles=()
  local broken_files=()
  
  # List of dotfiles that should be symlinked
  dotfiles=(
    ".asdfrc"
    ".galileorc"
    ".gitconfig"
    ".gitconfig_galileo"
    ".gitignore_global"
    ".irbrc"
    ".tool-versions"
    ".vimrc"
    ".zshrc"
  )
  
  for dotfile in "${dotfiles[@]}"; do
    if [[ ! -L "$HOME/$dotfile" ]]; then
      broken_files+=("$dotfile")
    fi
  done
  
  if (( ${#broken_files[@]} > 0 )); then
    echo "⚠️  The following dotfiles are not synced:"
    for file in "${broken_files[@]}"; do
      echo "   • $file"
    done
    echo "   Run 'bin/sync_dotfiles' to fix this"
    return 1
  else
    echo "✅ All dotfiles are properly synced"
    return 0
  fi
}

# Automatically ls after cd
cd () {
  builtin cd "$@";
  ls -a;
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

# Remove quarantine flag from downloaded apps
unquarantine() {
  if [[ -z "$1" ]]; then
    echo "Usage: unquarantine /path/to/app.app"
    echo "Removes macOS quarantine flag from downloaded applications"
    return 1
  fi
  
  local app_path="$1"
  
  # Check if path exists
  if [[ ! -e "$app_path" ]]; then
    echo "Error: '$app_path' does not exist"
    return 1
  fi
  
  # Check if quarantine flag exists
  if xattr -l "$app_path" 2>/dev/null | grep -q "com.apple.quarantine"; then
    echo "Removing quarantine flag from: $app_path"
    xattr -d com.apple.quarantine "$app_path"
    if [[ $? -eq 0 ]]; then
      echo "✅ Successfully unquarantined: $app_path"
    else
      echo "❌ Failed to remove quarantine flag"
      return 1
    fi
  else
    echo "ℹ️  No quarantine flag found on: $app_path"
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
export PATH="$BREW_PREFIX/opt/bison/bin:$PATH"  # Modern bison for parser generation
export PATH=/Applications/SnowSQL.app/Contents/MacOS:$PATH # 
export PATH="$PATH:$HOME/.lmstudio/bin"
export PATH="$PATH:$workspace/infra/helper-scripts/bin:$HOME/.local/bin"  # Personal scripts and tools

# Remove duplicates from PATH
typeset -U PATH

# ============================================================================
# ALIASES & SHORTCUTS
# ============================================================================

# Shell convenience
alias rezsh="source ~/.zshrc"
alias zshcfg="code -nw ~/workspace/infra/osx_setup/data/dotfiles/.zshrc"
alias omzcfg="code -nw ~/.oh-my-zsh"

# Dotfile sync monitoring
alias checkdots="check-dotfiles"
alias syncdots="\"$workspace\"/infra/osx_setup/bin/sync_dotfiles"

# macOS setup shortcuts
alias macos_setup="\"$workspace\"/infra/osx_setup/macos_setup"

# System hygiene with automatic directory handling
machygiene() {
  (cd "$workspace/infra/osx_setup" && bin/hygiene)
}

# Enhanced & tool overwrites
command -v bat >/dev/null 2>&1 && alias cat='bat'
if command -v eza >/dev/null 2>&1; then
  alias ls='eza -a'
  alias tree='eza --tree'
else
  alias ls="ls -aG"  # Enhanced ls: show all files and use color (fallback)
fi

# Ruby aliases
alias be="bundle exec"
alias rake="noglob rake"

# Directory navigation shortcuts
alias pd='pushd'
alias pp='popd'
alias dirs='dirs -v'

# Say the magic word
alias please='sudo $(fc -ln -1)'

# ============================================================================
# GIT SHORTHANDS
# ============================================================================
# Shorthand the stuff I most frequently use
alias gst='git status'
alias gaco='git aco'
alias gpub='git pub'
alias greup='git reup'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcob='git checkout -b'
alias gdff='git diff'
alias grbp='git rebase-and-push'

# ============================================================================
# PERIODIC UPDATE CHECKING
# ============================================================================

# Check if it's time to suggest running system hygiene
_check_osx_setup_update() {
  local last_update_file="$workspace/infra/osx_setup/data/.meta/last_hygiene_check"
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

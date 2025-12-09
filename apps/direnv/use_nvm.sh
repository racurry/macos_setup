# ~/.config/direnv/lib/use_nvm.sh

use_nvm() {
    watch_file .nvmrc
    [[ -f .nvmrc ]] || return 0
    
    source "${NVM_DIR:-$HOME/.nvm}/nvm.sh"
    nvm use
}

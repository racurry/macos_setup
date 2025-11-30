#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Install Oh My Zsh shell framework if not already present.

OPTIONS:
  -h, --help    Show this help message and exit

DESCRIPTION:
  This script checks if Oh My Zsh is already installed in ~/.oh-my-zsh.
  If not present, it downloads and installs Oh My Zsh using the official
  installer script with safe defaults (no shell change, keep existing .zshrc).

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      show_help
      exit 1
      ;;
  esac
done

print_heading "Ensure shell framework"

if [[ -d "${HOME}/.oh-my-zsh" ]]; then
  log_info "Oh My Zsh already installed"
  exit 0
fi

require_command curl

log_info "Installing Oh My Zsh"
if RUNZSH=no KEEP_ZSHRC=yes CHSH=no \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" >/dev/null
then
  log_info "Oh My Zsh installed. Open a new shell session to pick it up."
  exit 0
else
  fail "Oh My Zsh installer failed"
fi

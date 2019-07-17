#!/bin/sh -e

do_set_shell_to_zsh() {
  if  [[ $SHELL = '/bin/bash' ]]; then
    echo "    ✅  Changing shell to zsh"
    chsh -s /bin/zsh
  else
    echo "    🆗  Shell is already zsh"
  fi
}

do_set_preferences() {
  echo "----------------------------------------"
  echo "Setting shell preferences"
  echo "----------------------------------------"
  do_set_shell_to_zsh
}

do_set_preferences

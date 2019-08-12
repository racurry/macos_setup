#!/bin/sh -e

do_set_shell_to_zsh() {

  printf "    "
  printf "\e[1m"
  printf '%s ' "Changing shell to zsh"
  printf "\e[0m"

  if  [[ $SHELL = '/bin/bash' ]]; then
    chsh -s /bin/zsh
    printf "............................................."
    printf "\e[32mChanged! \e[0m"
    echo "✅"
  else
    printf "................................"
    printf "\e[3mShell is already zsh \e[0m"
    echo "🆗"
  fi
}

do_set_preferences() {
  printf "\n\e[33;1mSetting shell preferences\e[0m\n"
  printf "\e[33;1m--------------------------------------------------------------------------------\e[0m\n"

  do_set_shell_to_zsh

  printf "\n\e[32;1m    Shell preferences are set!\e[0m\n"
}

do_set_preferences

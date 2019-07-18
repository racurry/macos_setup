#!/usr/bin/env ruby

BREW_APPS = %w{rbenv git zsh bash-completion nvm yarn}
BREW_CASK_APPS = %w{caffeine spectacle alfred sublime-text
  dropbox idrive google-photos-backup-and-sync flux bartender
  iterm2 taskpaper lastpass itsycal }

def install_app(name:,command:'brew')
  if  `#{command} info #{name} 2>&1` !~ /Not installed/i
    puts "    🆗  #{name} is already installed.  Skipping"
  elsif system("#{command} install #{name} > /dev/null 2>&1")
    puts "    ✅  #{name} successfully installed!"
  else
    puts "    ⛔  Something went wrong with #{name}"
  end
end

def install_apps
  puts "-" * 40
  puts "Installing brew apps"
  puts "-" * 40
  BREW_APPS.each do |app|
    install_app(name: app)
  end

  puts "-" * 40
  puts "Installing brew cask apps"
  puts "-" * 40
  BREW_CASK_APPS.each do |app|
    install_app(name: app, command: 'brew cask')
  end
end

install_apps
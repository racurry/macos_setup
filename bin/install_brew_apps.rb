#!/usr/bin/env ruby

require_relative '../lib/terminal_helpers.rb'

BREW_APPS = %w{rbenv git zsh bash-completion nvm yarn}
BREW_CASK_APPS = %w{caffeine spectacle alfred sublime-text
  dropbox idrive google-photos-backup-and-sync flux bartender
  iterm2 taskpaper lastpass itsycal brave-browser}

def install_app(name:,command:'brew')
  initial_text = "#{name}..."
  pprint initial_text, indent: 1, style: :bold

  if  `#{command} info #{name} 2>&1` !~ /Not installed/i
    final_text = "Already installed! "
    text_opts = { style: :italic }
    emoji = "🆗"
  elsif system("#{command} install #{name} > /dev/null 2>&1")
    final_text = "Successfully installed!"
    text_opts = { style: :bold, color: :green }
    emoji = "✅"
  else
    final_text = "Something went wrong!"
    text_opts = { style: :bold, color: :red }
    emoji = "⛔"
  end

  print_column_fill final_text + emoji + initial_text, indent: 1
  pprint final_text, text_opts
  puts emoji
end

def install_apps
  section_header "Installing brew apps"
  BREW_APPS.each do |app|
    install_app(name: app)
  end
  section_footer "Done installing brew apps"

  section_header "Installing brew cask apps"
  BREW_CASK_APPS.each do |app|
    install_app(name: app, command: 'brew cask')
  end
  section_footer "Done installing brew cask apps"
end

install_apps
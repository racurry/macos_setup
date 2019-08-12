#!/usr/bin/env ruby

require_relative '../lib/terminal_helpers.rb'

SHELL_APPS = [
  {
    name: "XCode Command Line Tools",
    test: "gcc --help",
    command: "xcode-select --install"
  },
  {
    name: "Homebrew",
    command: "/usr/bin/ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"",
    test: "brew help"
  },
  {
    name: "Homebrew Cask",
    command: "brew tap caskroom/cask",
    test: "brew tap | grep caskroom/cask"
  }
]

def install_shell_app(name:, test:, command:)
  initial_text = "#{name}..."
  pprint initial_text, indent: 1, style: :bold

  if system("#{test} > /dev/null 2>&1")
    final_text = "Already installed! "
    text_opts = { style: :italic }
    emoji = "🆗"
  elsif system(command)
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
  section_header "Installing shell apps"

  SHELL_APPS.each do |app|
    install_shell_app(
      name: app[:name],
      test: app[:test],
      command: app[:command]
    )
  end
  section_footer "Done installing shell apps"
end

install_apps

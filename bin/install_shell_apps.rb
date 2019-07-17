#!/usr/bin/env ruby

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
  if system("#{test} > /dev/null 2>&1")
    puts "    🆗  #{name} is already installed.  Skipping"
  elsif system(command)
    puts "    ✅ #{name} successfully installed!"
  else
    puts "    ⛔ Something went wrong with #{name}"
  end
end

def install_apps
  puts "-" * 40
  puts "Installing shell apps"
  puts "-" * 40
  SHELL_APPS.each do |app|
    install_shell_app(
      name: app[:name],
      test: app[:test],
      command: app[:command]
    )
  end
end

install_apps

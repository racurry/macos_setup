#!/usr/bin/env ruby

system("./bin/setup_macos.sh")
system("./bin/install_shell_apps.rb")
system("./bin/install_brew_apps.rb")
system("./bin/install_brew_cask_apps.rb")
system("./bin/show_manual_todos.rb")


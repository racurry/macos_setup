#!/usr/bin/env ruby

system("./bin/setup_macos.sh")
system("./bin/install_shell_apps.rb")
system("./bin/install_brew_apps.rb")
system("./bin/install_brew_cask_apps.rb")

# manual_todo_list = ConfigurationListReader.from_file(MANUAL_STEPS_FILE, 'todos').configurations
# manual_task_reporter = ManualTaskReporter.new(manual_todo_list)
# manual_task_reporter.report!

# app_opener = ApplicationOpener.new(application_list)
# app_opener.open_apps!



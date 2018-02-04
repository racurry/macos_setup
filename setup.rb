#!/usr/bin/env ruby

require './class_files/configuration_list_reader.rb'
require './class_files/application_installer.rb'
require './class_files/manual_task_reporter.rb'
require './class_files/application_opener.rb'

APP_CONFIG_FILE = "./configs/applications.json"
MANUAL_STEPS_FILE = "./configs/manual_steps.json"

# Just get admin priveleges from the get; this may or may not help
system("sudo -v")

application_list = ConfigurationListReader.from_file(APP_CONFIG_FILE, 'applications').configurations
application_installer = ApplicationInstaller.new(application_list)
application_installer.install!

manual_todo_list = ConfigurationListReader.from_file(MANUAL_STEPS_FILE, 'todos').configurations
manual_task_reporter = ManualTaskReporter.new(manual_todo_list)
manual_task_reporter.report!

app_opener = ApplicationOpener.new(application_list)
app_opener.open_apps!

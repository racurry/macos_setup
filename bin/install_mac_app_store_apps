#!/usr/bin/env ruby

require_relative '../lib/terminal_helpers.rb'

APP_STORE_APPS_FILE = 'data/mac_app_store_apps.txt'

def install_app(name:,id:)
  initial_text = "#{name}..."
  pprint initial_text, indent: 1, style: :bold
  install_result = `mas install #{id}`

  if install_result =~ /already installed/i
    final_text = "Already installed! "
    text_opts = { style: :italic }
    emoji = "🆗"
  else
    final_text = "Successfully installed!"
    text_opts = { style: :bold, color: :green }
    emoji = "✅"
  end

  # TODO - I can't figure out how to actually get a real error state out of mas
  # I think it might be manual UI alerts

  # final_text = "Something went wrong!"
  # text_opts = { style: :bold, color: :red }
  # emoji = "⛔"

  print_column_fill final_text + emoji + initial_text, indent: 1
  pprint final_text, text_opts
  puts emoji
end

def mac_app_store_apps
  File.open(APP_STORE_APPS_FILE).read.split(/\n/)
end

def install_apps
  section_header "Installing macOS App Store apps"
  mac_app_store_apps.each do |app|
    id, name = app.split('-')
    id = id.strip
    install_app(id: id, name: name)
  end
  section_footer "Done installing macOS App Store apps"
end

install_apps
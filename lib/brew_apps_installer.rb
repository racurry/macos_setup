#!/usr/bin/env ruby

require_relative '../lib/terminal_helpers.rb'

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

def apps(data_file_name)
  File.open(data_file_name).read.split(/\n/)
end

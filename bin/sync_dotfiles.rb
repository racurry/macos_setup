#!/usr/bin/env ruby

require 'io/console'
require_relative '../lib/terminal_helpers.rb'

HOME_DIR = File.expand_path('~')
DOTFILES_PATH = '/data/dotfiles'
IGNORED_FILES = %w{.DS_Store .. .}

def local_dotfiles_dir
  "#{Dir.pwd}#{DOTFILES_PATH}"
end

def sync_file(dotfile)
  home_dir_dotfile = "#{HOME_DIR}/#{dotfile}"
  local_dotfile = "#{local_dotfiles_dir}/#{dotfile}"

  if !File.exists?(local_dotfile)
    raise "WHAT ARE YOU DOING IDIOT??  There is no #{local_dotfile}"
  end

  if File.exists?(home_dir_dotfile) || File.symlink?(home_dir_dotfile)

    pprint "    #{dotfile} already exists!", style: :bold
    print " What should I do?"
    pprint " (s=skip,r=replace,b=back up existing then replace): ", color: :cyan, style: :italic

    response = STDIN.getch

    case response
    when 's'
      pputs " Skipping #{dotfile}", color: :yellow, style: :italic
    when 'r'
      print " Replacing #{dotfile}..."
      File.delete(home_dir_dotfile)
      File.symlink(local_dotfile, home_dir_dotfile)
      pputs "Done!", color: :green, style: :bold
    when 'b'
      print " Backing up #{dotfile}..."
      File.rename(home_dir_dotfile, "#{home_dir_dotfile}.backup")
      pputs "Done!", color: :green, style: :bold
      print "    Linking #{dotfile}..."
      File.symlink(local_dotfile, home_dir_dotfile)
      pprint "Done!", color: :green, style: :bold
      pputs " The back up file is at #{home_dir_dotfile}.backup", style: :italic
    else
      pputs "That was gibberish, I am skipping", color: :red
    end
  else
    print "    #{dotfile} doesn't exist. Adding..."
    File.symlink(local_dotfile, home_dir_dotfile)
      pputs "Done!", color: :green, style: :bold
  end
end

def sync_dotfiles
  section_header "Syncing dotfiles"

  dotfiles = Dir.entries(local_dotfiles_dir)
  dotfiles.each do |dotfile|
    unless IGNORED_FILES.include?(dotfile)
      sync_file(dotfile)
    end
  end
end

sync_dotfiles
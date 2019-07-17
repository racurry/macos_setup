#!/usr/bin/env ruby

MANUAL_TODOS = [
  "Enable accessibility so Alfred will work",
  "Set up iDrive backup schedule",
  "Set up Google photo backup",
  "Download & install The Archive: https://zettelkasten.de/the-archive/"
]

def tell_me_what_to_do
  puts "-" * 40
  puts "The automation is over, go do these things"
  puts "-" * 40
  MANUAL_TODOS.each do | todo |
    puts "    - #{todo}"
  end
end

tell_me_what_to_do

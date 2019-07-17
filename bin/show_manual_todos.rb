#!/usr/bin/env ruby

DONE_FILE_NAME = '.todone'
MANUAL_TODOS_FILE = 'lib/manual_todos.txt'

def already_done
  if File.exists?(DONE_FILE_NAME)
    donezo = File.open(DONE_FILE_NAME)
    donezo.read.split(/\n/)
  else
    File.open(DONE_FILE_NAME, "w")
    []
  end
end

def all_todos
  File.open(MANUAL_TODOS_FILE).read.split(/\n/)
end

def things_to_do
  all_todos - already_done
end

def mark_as_done(todo)
  File.write(DONE_FILE_NAME, "\n#{todo}", mode: "a")
end

def tell_me_what_to_do
  puts "-" * 40
  puts "Do each of these!"
  puts "-" * 40

  things_to_do.each do |todo|
    puts "    - #{todo} (d=done,s=skip)"
    reply = gets.chomp
    if reply == 'd'
      mark_as_done(todo)
    end
  end

  left_to_do = things_to_do.count
  if left_to_do == 0
    puts "You don't have anything left to do!"
  else
    puts "Still #{left_to_do} things to do.  Run bin/show_manual_todos.rb any time to finish them"
  end
end

tell_me_what_to_do

#!/usr/bin/env ruby


def thing
  first_one = system("gcc --help > /dev/null 2>&1")
  second_one = system("flipzp --help > /dev/null 2>&1")
  puts "HEY I GOT #{first_one}"
  puts "HEY I GOT #{second_one}"
end

def install_shell_app(app_name, test, install_cmd)
  if system("#{test} > /dev/null 2>&1")
    puts "✅  #{app_name} is already installed.  Skipping"
  elsif system(install_cmd)
    puts "✅ #{app_name} successfully installed!"
  else
    puts "⛔ Something went wrong with #{app_name}"
  end
end

def install_applications
  install_shell_app("XCode Command Line Tools", "gcc --help", "xcode-select --install")
  install_shell_app("Homebrew", "brew help", "/usr/bin/ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"")
end

# Just get admin priveleges from the get; this may or may not help
system("sudo -v")

install_applications
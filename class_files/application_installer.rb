# require "shellwords"

# require "./applications.rb"
# require "./manual_steps.rb"


class ApplicationInstaller

  ALREADY = :already_installed
  SUCCESS = :successfully_installed
  FAILURE = :installation_failure

  attr_accessor :applications

  def initialize(applications)
    @applications = applications
  end

  def install!
    applications.each do |application|
      method = "install_#{application.type}".to_sym
      result = send(method, application)

      case result
      when ALREADY
        puts "🔸 #{application.name} is already installed.  Skipping"
      when SUCCESS
        puts "✅  #{application.name} successfully installed."
      when FAILURE
        puts "⛔ Something went wrong with #{application.name}.  Stopping setup"
        exit -1
      end
    end

    puts "Applications installed!"
  end

  private

  def install_shell(application)
    if system("#{application.test} > /dev/null 2>&1")
      ALREADY
    else
      if system(application.command)
        SUCCESS
      else
        FAILURE
      end
    end
  end

  def install_homebrew(application, cask:false)
    command = cask ? 'brew cask' : 'brew'
    check = `#{command} info #{application.package} 2>&1`
    if check !~ /Not installed/i
      ALREADY
    elsif system("#{command} install #{application.package}")
      SUCCESS
    else
      FAILURE
    end
  end

  def install_homebrewcask(application)
    install_homebrew(application, cask:true)
  end

end

class OSXConfigurator

  attr_reader :configurations
  def initialize(configurations)
    @configurations = configurations
  end

  def configure!
    close_system_prefs

    puts "Updating OS X settings"

    configurations.each do |configuration|
      commands = []
      commands << configuration.command unless configuration.command.nil?
      commands += configuration.commands unless configuration.commands.nil?

      success = true
      commands.each do |command|
        success = success && system(command)
      end

      if success
         puts "✅ #{configuration.description}"
      else
        puts "⛔ Something went wrong with: #{description.description}.  Stopping setup"
        exit -1
      end

    end
  end

  private
  def close_system_prefs
    # Close any open System Preferences panes, to prevent them from overriding
    # settings we’re about to change
    system("osascript -e 'tell application \"System Preferences\" to quit'")
  end
end

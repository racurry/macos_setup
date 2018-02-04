require 'shellwords'

class ApplicationOpener

  # Note that this thing only works with brew cask installed apps

  attr_reader :applications

  def initialize(applications)
    @applications = applications
  end

  def open_apps!
    apps_that_should_be_opened.each do |app|
      open_app(app)
    end
  end

  private

  def apps_that_should_be_opened
    applications.select do |app|
      app.open_after_install
    end
  end

  def open_app(app)
    app_path = determine_app_path(app)

    if app_path
      system("open #{Shellwords.escape(app_path)}")
    else
      puts "❗ I couldn't open #{app.name}.  Open it yourself"
    end
  end

  def determine_app_path(app)
    cask_info = `brew cask info #{app[:package]}`
    app_name = cask_info[/Artifacts(.*?)\(App/m, 1].strip
    if app_name
      "/Applications/#{app_name}"
    else
      nil
    end
  end

end
#!/bin/sh -e

# Set up all of the preferences

do_global_settings() {
  echo "    ✅  Setting up some global preferences..."
  # Always show scrollbars
  defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

  # Expand save panel by default
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

  # Expand print panel by default
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

  # Automatically quit printer app once the print jobs complete
  defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

  # Disable the “Are you sure you want to open this application?” dialog
  defaults write com.apple.LaunchServices LSQuarantine -bool false

  # Stop iTunes from responding to the keyboard media keys
  launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null
}

do_keyboard_setup() {
  echo "    ✅  Setting up keyboard preferences..."

  # Fast key repeats
  defaults write -g InitialKeyRepeat -int 15
  defaults write -g KeyRepeat -int 2
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
}

do_touchbar_setup() {
  echo "    ✅  Fixing the touchbar..."
  # Only show the regular control strip
  defaults write com.apple.touchbar.agent PresentationModeGlobal fullControlStrip
  # Show function keys on fn press
  defaults write com.apple.touchbar.agent PresentationModeFnModes -dict-add fullControlStrip functionKeys
}

do_dock_setup() {
  echo "    ✅  Setting up the dock..."

	# Only show active things in the dock
	defaults write com.apple.dock static-only -bool true
	# Autohide the dock
	defaults write com.apple.dock autohide -bool true
	# Put it on the left
  defaults write com.apple.Dock orientation -string "left"

    # Hot corners
  # Possible values:
  #  0: no-op
  #  2: Mission Control
  #  3: Show application windows
  #  4: Desktop
  #  5: Start screen saver
  #  6: Disable screen saver
  #  7: Dashboard
  # 10: Put display to sleep
  # 11: Launchpad
  # 12: Notification Center
  defaults write com.apple.dock wvous-bl-corner -int 10
  defaults write com.apple.dock wvous-bl-modifier -int 0

  # No dock bouncing, ever
  defaults write com.apple.dock no-bouncing -bool TRUE

  # Set icon size
  defaults write com.apple.dock tilesize -int 36
}

do_trackpad_setup() {
  echo "    ✅  Setting up the trackpad..."

  # Enable one-click taps
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

  # Trackpad: enable right click with two fingers
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
  defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
  defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
}

do_notification_settings() {
  echo "    ✅  Setting up notifications..."
  # TODO this will just turn back on tomorrow.
  # defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean true
  # defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturbDate -date "`date -u +\"%Y-%m-%d %H:%M:%S +000\"`"
}

do_fix_screenshots() {
  echo "    ✅  Fixing screenshot behavior..."
  # Make a screenshots folder
  mkdir -p ~/Screen\ Shots
  defaults write com.apple.screencapture location ~/Screen\ Shots

  # To hell with preview thumbnails
  defaults write com.apple.screencapture show-thumbnail -bool FALSE
}

do_finder_setup() {
  echo "    ✅  Setting up the finder..."
  # Show all extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  # Default new windows to column view
  defaults write com.apple.Finder FXPreferredViewStyle clmv
  # Allow quitting finder with cmd+Q
  defaults write com.apple.finder QuitMenuItem -bool true
  # Finder: show hidden files by default
  defaults write com.apple.finder AppleShowAllFiles -bool true
  # Finder: show status bar
  defaults write com.apple.finder ShowStatusBar -bool true
  # Finder: show path bar
  defaults write com.apple.finder ShowPathbar -bool true
  # Disable the warning when changing a file extension
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  # Disable the warning before emptying the Trash
  defaults write com.apple.finder WarnOnEmptyTrash -bool false
  # Empty Trash securely by default
  defaults write com.apple.finder EmptyTrashSecurely -bool true
  # Set Desktop as the default location for new Finder windows
# For other paths, use `PfLo` and `file:///full/path/here/`
  defaults write com.apple.finder NewWindowTarget -string "PfDe"
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"
  # Show icons for hard drives, servers, and removable media on the desktop
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
}

do_kill_running_apps()  {
  echo "    ✅  Restarting some things..."
  killall Dock
  killall ControlStrip
  killall NotificationCenter
  killall Finder
  # TODO - how do I kill the trackpad and the keyboard?
}

do_setup() {
  echo "----------------------------------------"
  echo "Setting up macOS"
  echo "----------------------------------------"
  do_global_settings
  do_keyboard_setup
  do_trackpad_setup
  do_dock_setup
  do_touchbar_setup
  do_fix_screenshots
  do_finder_setup
  do_notification_settings

  do_kill_running_apps
  echo " macOS is setup.  I think you need to restart, though"
}

# Wipe everything back to factory defaults
do_config_resets() {
  # TODO - what about everything else?

  # dock
  defaults delete com.apple.dock

  # Finder
  defaults write NSGlobalDomain AppleShowAllExtensions -bool false

}

do_setup


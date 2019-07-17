#!/bin/sh -e

# Set up all of the preferences

do_keyboard_setup() {
  echo "Setting up keyboard preferences..."

  # Fast key repeats
  defaults write -g InitialKeyRepeat -int 15
  defaults write -g KeyRepeat -int 2
}

do_touchbar_setup() {
  echo "    ✅ Fixing the touchbar..."
  # Only show the regular control strip
  defaults write com.apple.touchbar.agent PresentationModeGlobal fullControlStrip
  # Show function keys on fn press
  defaults write com.apple.touchbar.agent PresentationModeFnModes -dict-add fullControlStrip functionKeys
}

do_dock_setup() {
  echo "    ✅ Setting up the dock..."

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
}

do_trackpad_setup() {
  echo "    ✅ Setting up the trackpad..."

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

do_kill_running_apps()  {
  killall Dock
  killall ControlStrip
  # TODO - how do I kill the trackpad or whatever
}

# Wipe everything back to factory defaults
do_config_resets() {
  # TODO - what about everything else?
  defaults delete com.apple.dock
}

do_setup() {
  echo "----------------------------------------"
  echo "Setting up macOS"
  echo "----------------------------------------"
  do_keyboard_setup
  do_trackpad_setup
  do_dock_setup
  do_touchbar_setup
  do_kill_running_apps
}

do_setup


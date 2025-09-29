#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS] COMMAND

Apply macOS system preferences and defaults.

COMMANDS:
  global       Apply global macOS defaults (scrollbars, save panels, etc.)
  input        Apply keyboard and input defaults (key repeat, autocorrect, etc.)
  dock         Apply Dock and Spaces defaults (position, size, animations, etc.)
  finder       Apply Finder defaults (extensions, hidden files, paths, etc.)
  misc         Apply miscellaneous defaults (screenshots, screensaver, sounds, etc.)
  all          Apply all settings (equivalent to running all commands above)

OPTIONS:
  -h, --help   Show this help message and exit

EXAMPLES:
  $(basename "$0") global           # Apply only global settings
  $(basename "$0") dock             # Apply only dock settings
  $(basename "$0") all              # Apply all settings

NOTE: Some commands require sudo credentials to be cached.
Run scripts/bash/sudo_keepalive.sh first if needed.
EOF
}

apply_global_settings() {
  print_heading "Apply global macOS defaults"

  require_command defaults

  if ! sudo -n true 2>/dev/null; then
    fail "sudo credentials not cached; run scripts/bash/sudo_keepalive.sh first"
  fi

  log_info "Always show scrollbars"
  defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

  log_info "Expand save panels by default"
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

  log_info "Expand print panel by default"
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

  log_info "Automatically quit printer app when jobs complete"
  defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

  log_info "Disable automatic display brightness adjustment"
  sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Automatic Display Enabled" -bool false

  log_info "Disable close-windows-on-quit"
  defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool true

  log_info "Global defaults applied"
}

apply_input_settings() {
  print_heading "Apply keyboard and input defaults"

  require_command defaults

  # Key repeat settings
  log_info "Setting fast key repeat"
  defaults write -g InitialKeyRepeat -int 15
  log_info "Setting key repeat speed"
  defaults write -g KeyRepeat -int 2

  # Text input toggles
  log_info "Disabling press-and-hold for special characters"
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

  log_info "Enabling full keyboard access for all controls"
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

  log_info "Disabling automatic spelling correction"
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

  log_info "Disabling smart quotes"
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

  log_info "Disabling smart dashes"
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

  log_info "Disabling auto-capitalization"
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

  log_info "Disabling auto period substitution"
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

  log_info "Enabling text replacement globally"
  defaults write -g WebAutomaticTextReplacementEnabled -bool true

  log_info "Keyboard and input defaults applied"
}

apply_dock_settings() {
  print_heading "Apply Dock and Spaces defaults"

  require_command defaults

  log_info "Clearing persistent apps from Dock"
  defaults write com.apple.dock persistent-apps -array

  log_info "Show only open applications in Dock"
  defaults write com.apple.dock static-only -bool true

  log_info "Automatically hide Dock"
  defaults write com.apple.dock autohide -bool true

  log_info "Position Dock on left"
  defaults write com.apple.dock orientation -string "left"

  log_info "Setting Dock icon size"
  defaults write com.apple.dock tilesize -int 36

  log_info "Disable dock bouncing"
  defaults write com.apple.dock no-bouncing -bool true

  log_info "Disable automatically rearranging Spaces"
  defaults write com.apple.dock mru-spaces -bool false

  log_info "Speed up Mission Control animations"
  defaults write com.apple.dock expose-animation-duration -float 0.1

  log_info "Configure hot corners"
  defaults write com.apple.dock wvous-bl-corner -int 5
  defaults write com.apple.dock wvous-bl-modifier -int 0

  log_info "Restarting Dock to apply changes"
  killall Dock 2>/dev/null || true

  log_info "Dock and Spaces defaults applied"
}

apply_finder_settings() {
  print_heading "Apply Finder defaults"

  require_command defaults
  require_command chflags

  log_info "Show all filename extensions"
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  log_info "Set Finder new window target to Desktop"
  defaults write com.apple.finder NewWindowTarget -string "PfDe"
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

  log_info "Show hidden files"
  defaults write com.apple.finder AppleShowAllFiles -bool true

  log_info "Show status bar"
  defaults write com.apple.finder ShowStatusBar -bool true

  log_info "Show path bar"
  defaults write com.apple.finder ShowPathbar -bool true

  log_info "Show icons for drives and media on Desktop"
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

  log_info "Disable extension change warning"
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

  log_info "Disable empty Trash warning"
  defaults write com.apple.finder WarnOnEmptyTrash -bool false

  log_info "Reveal ~/Library"
  chflags nohidden "${HOME}/Library"

  log_info "Restarting Finder"
  killall Finder 2>/dev/null || true

  log_info "Finder defaults applied"
}

apply_misc_settings() {
  print_heading "Apply miscellaneous defaults"

  require_command defaults

  if ! sudo -n true 2>/dev/null; then
    fail "sudo credentials not cached; run scripts/bash/sudo_keepalive.sh first"
  fi

  log_info "Ensure Screenshots directory exists"
  mkdir -p "${HOME}/Screenshots"

  log_info "Set screenshot location"
  defaults write com.apple.screencapture location "${HOME}/Screenshots"

  log_info "Disable screenshot thumbnails"
  defaults write com.apple.screencapture show-thumbnail -bool false

  log_info "Use PNG for screenshots"
  defaults write com.apple.screencapture type -string "png"

  log_info "Set screensaver"
  defaults -currentHost write com.apple.screensaver moduleDict -dict \
    path -string "/System/Library/Screen Savers/Flurry.saver" \
    moduleName -string "Flurry" \
    type -int 0

  log_info "Disable screensaver idle timeout"
  defaults -currentHost write com.apple.screensaver idleTime -int 0

  log_info "Set alert sound to Submarine"
  defaults write .GlobalPreferences com.apple.sound.beep.sound "/System/Library/Sounds/Submarine.aiff"

  log_info "Show battery percentage"
  defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true

  log_info "Refresh settings"
  killall "SystemUIServer" 2>/dev/null || true
  killall "TextInputMenuAgent" 2>/dev/null || true

  log_info "Misc defaults applied"
}

apply_all_settings() {
  apply_global_settings
  apply_input_settings
  apply_dock_settings
  apply_finder_settings
  apply_misc_settings
}

# Parse command line arguments
case "${1:-}" in
  global)
    apply_global_settings
    ;;
  input)
    apply_input_settings
    ;;
  dock)
    apply_dock_settings
    ;;
  finder)
    apply_finder_settings
    ;;
  misc)
    apply_misc_settings
    ;;
  all)
    apply_all_settings
    ;;
  -h|--help|help)
    show_help
    exit 0
    ;;
  "")
    echo "Error: No command specified." >&2
    echo "Run '$(basename "$0") --help' for usage information." >&2
    exit 1
    ;;
  *)
    echo "Error: Unknown command '$1'" >&2
    echo "Run '$(basename "$0") --help' for usage information." >&2
    exit 1
    ;;
esac
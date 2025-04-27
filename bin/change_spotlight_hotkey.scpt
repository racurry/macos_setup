tell application "System Settings"
    activate
    delay 1
    # Navigate directly to Keyboard Shortcuts section
    do shell script "open 'x-apple.systempreferences:com.apple.Keyboard-Settings.extension?Shortcuts'"
    delay 2
    
    tell application "System Events"
        # Select Spotlight in the sidebar
        click text "Spotlight" of UI element 1 of row of table 1 of scroll area 1 of group 1 of window "Keyboard" of application process "System Settings"
        delay 1
        
        # Click on "Show Spotlight search" row
        click row 1 of table 1 of scroll area 2 of group 1 of window "Keyboard" of application process "System Settings"
        delay 1
        
        # Double-click on shortcut to edit it
        click UI element 2 of row 1 of table 1 of scroll area 2 of group 1 of window "Keyboard" of application process "System Settings"
        delay 1
        
        # Input new shortcut: Control+Space
        key code 49 using {control down}
        delay 1
        
        # Press Return to confirm
        key code 36
        delay 1
        
        # Click Done button if available
        try
            click button "Done" of window "Keyboard" of application process "System Settings"
        end try
    end tell
    quit
end tell
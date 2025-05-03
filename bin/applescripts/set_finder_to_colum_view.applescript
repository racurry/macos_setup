tell application "Finder"
    activate
    try
        -- Close any open dialog windows
        tell application "System Events"
            tell process "Finder"
                repeat while (exists (window 1 whose subrole is "AXDialog"))
                    click button "Cancel" of window 1 whose subrole is "AXDialog"
                end repeat
            end tell
        end tell

        -- Close all windows except first one
        repeat while (count of Finder windows) > 1
            close window 2
        end repeat
        
        -- Create window if none exists
        if not (exists window 1) then
            make new Finder window
        end if

        -- Set the target folder to root directory
        set target_folder to startup disk
        set target of window 1 to target_folder
        
        -- Set the view to Column view
        set current view of Finder window 1 to column view
        
        -- Open View Options dialog with Cmd+J
        tell application "System Events"
            tell process "Finder"
                keystroke "j" using command down
                
                -- Wait for dialog to appear
                delay 1
                
                -- Find the View Options dialog (system floating window)
                set viewOptionsWindow to first window whose subrole is "AXSystemFloatingWindow"
                
                -- Try to interact with the checkboxes
                tell viewOptionsWindow
                    -- First try: Look for checkboxes directly
                    set allCheckboxes to (every checkbox)
                    log "Found " & (count of allCheckboxes) & " checkboxes"
                    
                    -- Click each checkbox
                    repeat with cb in allCheckboxes
                        log "Clicking checkbox: " & (name of cb)
                        click cb
                        delay 0.2
                    end repeat
                    
                    log "Finished processing checkboxes"
                end tell
            end tell
        end tell
        
        -- Ask before restarting Finder
        log "Would you like to restart Finder to apply changes? (y/n)"
        set userInput to do shell script "echo -n 'Restart Finder? (y/n): '; read response; echo $response"
        if userInput is "y" then
            do shell script "killall Finder"
        end if
    on error errMsg
        log "Error setting Column view as default: " & errMsg
    end try
end tell
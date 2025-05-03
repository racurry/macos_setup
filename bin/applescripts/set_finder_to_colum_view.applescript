-- This shit still doesn't work

tell application "Finder"
    try
        -- Kill Finder to ensure clean state
        do shell script "killall Finder"
        delay 1
        
        -- Ensure Finder is active
        activate application "Finder"
        delay 1
        
        -- Open startup disk in a new window
        open startup disk
        
        -- Set the view to Column view
        set current view of Finder window 1 to column view
        
        -- Open View Options dialog with Cmd+J
        tell application "System Events"
            tell process "Finder"
                keystroke "j" using command down
                
                -- Find the View Options dialog (system floating window)
                repeat 5 times
                    try
                        set viewOptionsWindow to first window whose subrole is "AXSystemFloatingWindow"
                        exit repeat
                    on error
                        delay 0.5
                    end try
                end repeat
                
                -- Try to interact with the checkboxes
                tell viewOptionsWindow
                    -- First try: Look for checkboxes directly
                    set allCheckboxes to (every checkbox)
                    log "Found " & (count of allCheckboxes) & " checkboxes"
                    
                    -- Click each checkbox only if it's not already checked
                    repeat with cb in allCheckboxes
                        set cbValue to (value of cb)
                        log "Checkbox: " & (name of cb) & " - Value: " & cbValue
                        
                        if cbValue is 0 then
                            log "Clicking checkbox: " & (name of cb)
                            click cb
                            delay 0.2
                        else
                            log "Checkbox already checked: " & (name of cb)
                        end if
                    end repeat
                    
                    log "Finished processing checkboxes"
                end tell
            end tell
        end tell

        do shell script "killall Finder"
    on error errMsg
        log "Error setting Column view as default: " & errMsg
    end try
end tell
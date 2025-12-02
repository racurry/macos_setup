# DEVONthink

Document management application with AI-powered organization, search, and sync.

## Installation

```bash
brew install --cask devonthink
```

## Setup

This repo provides AppleScript development tools for DEVONthink custom scripts:

```bash
./apps/devonthink/devonthink.sh watch   # Compile scripts on change
./apps/devonthink/devonthink.sh deploy  # Compile and deploy to DEVONthink
```

Scripts in `src/` are compiled to `build/` and deployed to `~/Library/Application Scripts/com.devon-technologies.think/`.

## Manual Setup

Complete these steps after installation:

1. **Activate license** - DEVONthink menu > Enter License, or log in at [devontechnologies.com](https://www.devontechnologies.com/support/faq/my-licenses) and click Activate
2. **Grant Full Disk Access** - System Settings > Privacy & Security > Full Disk Access > add DEVONthink
3. **Configure sync** - DEVONthink > Preferences > Sync (see Syncing section below)
4. **Install add-ons** - DEVONthink > Install Add-Ons (installs bundled scripts)

## Syncing Preferences

**App-managed sync.** DEVONthink syncs databases (not app preferences) via its built-in sync engine to iCloud, Dropbox, WebDAV, or local network.

To set up sync:

1. Open DEVONthink > Preferences > Sync
2. Add a sync location (iCloud, Dropbox, or WebDAV)
3. Set an encryption key (AES-256; same key needed on all devices)
4. Enable databases to sync

**Note:** iCloud sync can be slower and requires temporary extra disk space. Dropbox may double storage unless you enable Selective Sync to exclude `Apps/DEVONthink Packet Sync`.

Application preferences (in `~/Library/Preferences/com.devon-technologies.think.plist`) do not sync automatically. For a new Mac, use Migration Assistant or manually copy the plist.

## Maintenance

| Task | Command | When |
|------|---------|------|
| Verify & Repair | Tools > Verify & Repair | Monthly or if issues arise |
| Optimize | File > Optimize Database | Every few months |
| Verify all | Script > Data > Verify & Optimize Databases | Periodic check of all databases |

DEVONthink creates internal backups weekly. Restore via Option + File > Restore Backup.

## References

- [DEVONthink Documentation](https://download.devontechnologies.com/download/devonthink/3.8.2/DEVONthink.help/Contents/Resources/pgs/gettingstarted.html)
- [Sync Guide](https://www.devontechnologies.com/blog/20220628-devonthink-sync)
- [Smart Rules Scripts](https://download.devontechnologies.com/download/devonthink/3.8.2/DEVONthink.help/Contents/Resources/pgs/automation-smartrulescripts.html)
- [Database Maintenance](https://www.devontechnologies.com/blog/20240723-devonthink-maintenance)

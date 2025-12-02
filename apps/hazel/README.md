# Hazel

Automated file organization for macOS by Noodlesoft.

## Installation

```bash
brew install --cask hazel
```

## Manual Setup

Complete these steps after installation:

1. **Grant Full Disk Access** - Required for Hazel to access protected folders:
   - Open Hazel preferences and go to Info tab
   - Hold Option key and click "Debug..."
   - Click "Show HazelHelper in Finder"
   - Open System Settings > Privacy & Security > Full Disk Access
   - Drag HazelHelper into the list and enable it

2. **Enter license** - Open Hazel preferences and enter your license key

3. **Configure rule sync** - See Syncing Preferences below

## Syncing Preferences

**App-managed sync to cloud drive.** Hazel has built-in rule sync that saves `.hazelrules` files to a folder you choose. Use Dropbox or Google Drive for sync storage.

To set up sync for each folder:
1. Select a folder in Hazel
2. Click Action menu > Rule Sync Settings
3. Click "Set up new sync file"
4. Save to your cloud drive sync folder

On other Macs, use "Use existing sync file" to connect to the same rules.

**Limitations:**
- Syncs complete rule sets per folder, not individual rules
- Enabled/disabled state does not sync
- Rules may contain machine-specific paths that need adjustment

**Avoid iCloud Drive** - The Noodlesoft developer has warned against syncing Hazel data via iCloud due to potential data corruption and sync issues.

## References

- [Hazel Manual - Sync Rules](https://www.noodlesoft.com/manual/hazel/work-with-folders-rules/manage-rules/sync-rules/)
- [Hazel Manual - Export Rules](https://www.noodlesoft.com/manual/hazel/work-with-folders-rules/manage-rules/export-rules/)
- [Full Disk Access Setup](https://www.noodlesoft.com/kb/giving-hazel-full-disk-access-on-mojave/)
- [Restoring from Backups](https://www.noodlesoft.com/kb/restoring-hazel-from-backups/)

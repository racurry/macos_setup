# Ice

> ⚠️ Manually installed (beta) - waiting for stable Tahoe fix

Menu bar management for macOS.

## Current Status

The stable Homebrew version (`jordanbaird-ice` cask, v0.11.12) crashes on macOS Tahoe (26.x). The fix is only available in the beta release.

**Installed version**: 0.11.13-dev.2 (macOS Tahoe Beta 2)

### Related Issues

- [Ice crashes on click in macOS 26](https://github.com/jordanbaird/Ice/issues/821)
- [Ice Bar causes crashes](https://github.com/jordanbaird/Ice/issues/786)
- [Ice stops working in Tahoe](https://github.com/jordanbaird/Ice/issues/709)

### Ideal State

Once a stable release with Tahoe fixes is published, switch back to Homebrew:

```bash
# Remove manual install
rm -rf /Applications/Ice.app

# Install via Homebrew
brew install --cask jordanbaird-ice
```

## Installation (Current Workaround)

Download and install the beta manually:

```bash
cd /tmp
curl -L -o Ice-beta.zip "https://github.com/jordanbaird/Ice/releases/download/0.11.13-dev.2/Ice.zip"
unzip -o Ice-beta.zip
mv Ice.app /Applications/
rm Ice-beta.zip
```

## Manual Setup

- [ ] Configure Ice settings
- [ ] Grant accessibility permissions when prompted

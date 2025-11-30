# 1Password SSH Agent Configuration

> ⚠️ Requires Homebrew

Configuration files for the 1Password SSH agent.

## Files

- `agent.personal.toml` - Personal machine config (personal key only)
- `agent.work.toml` - Work machine config (work key first, personal key second)

## Usage

The `1password.sh` script copies the appropriate file to `~/.config/1password/ssh/agent.toml` based on `SETUP_MODE`.

## Documentation

- [1Password SSH Agent Config](https://developer.1password.com/docs/ssh/agent/config)

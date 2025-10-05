#!/bin/bash

# ===============================================================================
# SSH Key Management Script
# ===============================================================================
#
# This script automates the process of setting up SSH keys from 1Password for
# either work or personal use, based on the SETUP_MODE environment variable.
#
# EXECUTION STEPS:
# 1. Configuration Selection:
#    - Check SETUP_MODE environment variable (work/personal)
#    - Set appropriate key types, 1Password item IDs, email, vault, and account
#    - Display which mode is being used
#
# 2. Directory Setup:
#    - Create ~/.ssh directory with proper permissions (700)
#    - Create ~/.ssh/backups directory for storing old key backups
#
# 3. Key Export Process (for each SSH key):
#    - Backup any existing keys with timestamp to ~/.ssh/backups/
#    - Export private key from 1Password using op CLI tool
#    - Set proper permissions on private key (600)
#    - Export public key from 1Password, or generate it from private key if not found
#    - Set proper permissions on public key (644)
#
# 4. Git Signing Configuration (for GitHub keys only):
#    - Update ~/.ssh/allowed_signers file
#    - Remove any existing entries for the current email
#    - Add new entry mapping email to the SSH public key for commit signing
#
# 5. SSH Config Update:
#    - Update ~/.ssh/config file to point to the correct identity files
#    - Map key types to their corresponding hosts (e.g., github -> github.com)
#    - Update IdentityFile entries for each host
#    - Clean up temporary backup files
#
# The script handles both work and personal SSH key configurations, backing up
# existing keys before replacement, and ensuring proper file permissions throughout.
#
# ===============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/bash/common.sh
source "${SCRIPT_DIR}/../../lib/bash/common.sh"

# Configuration constants
WORK_KEY_ID="4nqynmwddwpx7dq5rjvwi7r2l4"
WORK_EMAIL="acurry@galileo.io"

PERSONAL_KEY_ID="vusx65kxj234sajwo62vobroxe"
PERSONAL_EMAIL="aaroncurry@gmail.com"

# Global variables
mode="personal"

# Function to display usage information
show_usage() {
  echo "Usage: $0 [options] [command]"
  echo ""
  echo "Commands:"
  echo "  setup [work|personal]  - Complete SSH key setup (default)"
  echo "  config [work|personal] - Configure mode only"
  echo "  dirs                   - Create SSH directories"
  echo "  export [work|personal] - Export keys from 1Password"
  echo "  signing [work|personal] - Configure git signing"
  echo "  ssh-config [work|personal] - Update SSH config"
  echo "  help                   - Show this help"
  echo ""
  echo "Options:"
  echo "  -h, --help            - Show this help"
  echo ""
  echo "Environment:"
  echo "  SETUP_MODE            - Set to 'work' or 'personal' (overridden by command args)"
}

# Function to configure the mode (work/personal)
configure_mode() {
  local requested_mode="$1"

  # Use argument if provided, otherwise fall back to SETUP_MODE
  if [[ -n "$requested_mode" ]]; then
    mode="$requested_mode"
  elif [[ -n "${SETUP_MODE}" ]]; then
    mode="${SETUP_MODE}"
  fi

  if [[ "${mode}" == "work" ]]; then
    echo "Using work mode: exporting both work and personal GitHub SSH keys"
  else
    mode="personal"
    echo "Using personal mode: exporting only personal GitHub SSH keys"
  fi
}

# Function to create SSH directories with proper permissions
setup_directories() {
  echo "Setting up SSH directories..."
  mkdir -p "${PATH_SSH_DIR}"
  chmod 700 "${PATH_SSH_DIR}"
  mkdir -p "${PATH_SSH_BACKUPS}"
  echo "Created ${PATH_SSH_DIR} and ${PATH_SSH_BACKUPS} with proper permissions"
}

# Function to backup existing file if it exists
backup_if_exists() {
  local file=$1
  if [[ -f "$file" ]]; then
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local basename
    basename=$(basename "$file")
    local backup_path="${PATH_SSH_BACKUPS}/${timestamp}_${basename}"
    mv "$file" "$backup_path"
    echo "Backed up existing $file to $backup_path"
  fi
}

# Function to export a single SSH key from 1Password
export_single_ssh_key() {
  local key_id="$1"
  local key_prefix="$2"
  local vault="$3"
  local account="$4"

  local key_name="id_${key_prefix}_github"

  echo "Exporting GitHub SSH key (${key_id}) from ${vault} vault"

  # Backup existing keys if they exist
  backup_if_exists "${PATH_SSH_DIR}/${key_name}"
  backup_if_exists "${PATH_SSH_DIR}/${key_name}.pub"

  # Export private key
  op item get "${key_id}" --account "${account}" --vault "${vault}" --fields "private key" --reveal | sed 's/^"//;s/"$//' | sed '/^$/d' > "${PATH_SSH_DIR}/${key_name}"

  chmod 600 "${PATH_SSH_DIR}/${key_name}"
  echo "Exported private key to ${PATH_SSH_DIR}/${key_name}"

  # Export public key
  op item get "${key_id}" --account "${account}" --vault "${vault}" --fields "public key" > "${PATH_SSH_DIR}/${key_name}.pub" 2>/dev/null || true

  if [[ -f "${PATH_SSH_DIR}/${key_name}.pub" ]]; then
    chmod 644 "${PATH_SSH_DIR}/${key_name}.pub"
    echo "Exported public key to ${PATH_SSH_DIR}/${key_name}.pub"
  else
    echo "No public key found for ${key_id}, generating from private key..."
    ssh-keygen -y -f "${PATH_SSH_DIR}/${key_name}" > "${PATH_SSH_DIR}/${key_name}.pub"
    chmod 644 "${PATH_SSH_DIR}/${key_name}.pub"
    echo "Generated public key at ${PATH_SSH_DIR}/${key_name}.pub"
  fi
}

# Function to export SSH keys from 1Password
export_ssh_keys() {
  echo "Exporting GitHub SSH keys from 1Password..."

  if [[ "${mode}" == "work" ]]; then
    # Export work key
    export_single_ssh_key "${WORK_KEY_ID}" "work" "Employee" "galileo.1password.com"
  fi
  # Export only personal key
  export_single_ssh_key "${PERSONAL_KEY_ID}" "personal" "Private" "my.1password.com"

  echo "SSH key export complete"
}

# Function to configure Git signing for a single key
configure_single_git_signing() {
  local key_prefix="$1"
  local email="$2"

  local key_name="id_${key_prefix}_github"

  if [[ ! -f "${PATH_SSH_DIR}/${key_name}.pub" ]]; then
    echo "Warning: Public key ${PATH_SSH_DIR}/${key_name}.pub not found, skipping signing config"
    return 0
  fi

  public_key_content=$(cat "${PATH_SSH_DIR}/${key_name}.pub")

  # Create or update allowed_signers
  allowed_signers="${PATH_SSH_DIR}/allowed_signers"

  # Remove any existing entries for this email
  if [[ -f "${allowed_signers}" ]]; then
    grep -v "^${email}" "${allowed_signers}" > "${allowed_signers}.tmp" || true
    mv "${allowed_signers}.tmp" "${allowed_signers}"
  fi

  # Add new entry
  echo "${email} ${public_key_content}" >> "${allowed_signers}"
  echo "Added ${email} to allowed_signers"
}

# Function to configure Git signing with SSH keys
configure_git_signing() {
  echo "Configuring Git signing with GitHub SSH keys..."

  if [[ "${mode}" == "work" ]]; then
    # Configure work key
    configure_single_git_signing "work" "${WORK_EMAIL}"
  fi
  # Configure only personal key
  configure_single_git_signing "personal" "${PERSONAL_EMAIL}"

  echo "Git signing configuration complete"
}

# Function to update SSH config
update_ssh_config() {
  echo "Updating SSH configuration..."

  if [[ ! -f "${PATH_SSH_DIR}/config" ]]; then
    echo "Warning: ${PATH_SSH_DIR}/config not found, skipping config update"
    return 0
  fi

  # For SSH config, we only need to set the primary key (work key in work mode, personal key in personal mode)
  local key_prefix

  if [[ "${mode}" == "work" ]]; then
    key_prefix="work"
  else
    key_prefix="personal"
  fi

  key_name="id_${key_prefix}_github"

  # Update IdentityFile for github.com
  if grep -q "^Host github.com" "${PATH_SSH_DIR}/config"; then
    sed -i.bak "/^Host github.com/,/^Host / s|IdentityFile.*|IdentityFile ${PATH_SSH_DIR}/${key_name}|" "${PATH_SSH_DIR}/config"
    echo "Updated IdentityFile for github.com to ${PATH_SSH_DIR}/${key_name}"
  else
    echo "Warning: Host github.com not found in ${PATH_SSH_DIR}/config"
  fi

  # Remove backup file
  rm -f "${PATH_SSH_DIR}/config.bak"
  echo "SSH configuration update complete"
}

# Function to run the complete setup process
run_complete_setup() {
  local setup_mode="$1"

  configure_mode "$setup_mode"
  setup_directories
  export_ssh_keys
  configure_git_signing
  update_ssh_config
  echo "Complete SSH setup finished successfully"
}

# Main function to handle command-line arguments
main() {
  local command="setup"
  local mode_arg=""

  # Parse command line arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help|help)
        show_usage
        exit 0
        ;;
      setup|config|dirs|export|signing|ssh-config)
        command="$1"
        shift
        if [[ $# -gt 0 && ($1 == "work" || $1 == "personal") ]]; then
          mode_arg="$1"
          shift
        fi
        ;;
      work|personal)
        mode_arg="$1"
        shift
        ;;
      *)
        echo "Error: Unknown argument '$1'"
        show_usage
        exit 1
        ;;
    esac
  done

  # Execute the requested command
  case "$command" in
    setup)
      run_complete_setup "$mode_arg"
      ;;
    config)
      configure_mode "$mode_arg"
      ;;
    dirs)
      setup_directories
      ;;
    export)
      configure_mode "$mode_arg"
      export_ssh_keys
      ;;
    signing)
      configure_mode "$mode_arg"
      configure_git_signing
      ;;
    ssh-config)
      configure_mode "$mode_arg"
      update_ssh_config
      ;;
    *)
      echo "Error: Unknown command '$command'"
      show_usage
      exit 1
      ;;
  esac
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

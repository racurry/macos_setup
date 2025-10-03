#!/bin/bash

set -e

# SSH keys: parallel arrays for key_type and 1password_item_id
WORK_KEY_TYPES=("github")
WORK_KEY_IDS=("3dn2nyl7mqefnd46fmmheph75a")
WORK_EMAIL="acurry@galileo.io"

PERSONAL_KEY_TYPES=("github")
PERSONAL_KEY_IDS=("vusx65kxj234sajwo62vobroxe")
PERSONAL_EMAIL="aaroncurry@gmail.com"

# Select keys based on SETUP_MODE
if [[ "${SETUP_MODE}" == "work" ]]; then
  KEY_TYPES=("${WORK_KEY_TYPES[@]}")
  KEY_IDS=("${WORK_KEY_IDS[@]}")
  EMAIL="${WORK_EMAIL}"
  mode="work"
  echo "Using work SSH keys"
else
  KEY_TYPES=("${PERSONAL_KEY_TYPES[@]}")
  KEY_IDS=("${PERSONAL_KEY_IDS[@]}")
  EMAIL="${PERSONAL_EMAIL}"
  mode="personal"
  echo "Using personal SSH keys"
fi

# Ensure directories exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh
mkdir -p ~/.ssh/backups

# Backup existing file if it exists
backup_if_exists() {
  local file=$1
  if [[ -f "$file" ]]; then
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local basename
    basename=$(basename "$file")
    local backup_path=~/.ssh/backups/${timestamp}_${basename}
    mv "$file" "$backup_path"
    echo "Backed up existing $file to $backup_path"
  fi
}

# Export each SSH key
for i in "${!KEY_TYPES[@]}"; do
  key_type="${KEY_TYPES[$i]}"
  key_id="${KEY_IDS[$i]}"
  key_name="id_${mode}_${key_type}"

  echo "Exporting SSH key: ${key_type} (${key_id})"

  # Backup existing keys if they exist
  backup_if_exists ~/.ssh/"${key_name}"
  backup_if_exists ~/.ssh/"${key_name}.pub"

  # Export private key
  op document get "${key_id}" --output ~/.ssh/"${key_name}" 2>/dev/null || \
    op item get "${key_id}" --fields "private key" > ~/.ssh/"${key_name}"

  chmod 600 ~/.ssh/"${key_name}"
  echo "Exported private key to ~/.ssh/${key_name}"

  # Export public key
  op item get "${key_id}" --fields "public key" > ~/.ssh/"${key_name}.pub" 2>/dev/null || true

  if [[ -f ~/.ssh/"${key_name}.pub" ]]; then
    chmod 644 ~/.ssh/"${key_name}.pub"
    echo "Exported public key to ~/.ssh/${key_name}.pub"
  else
    echo "No public key found for ${key_id}, generating from private key..."
    ssh-keygen -y -f ~/.ssh/"${key_name}" > ~/.ssh/"${key_name}.pub"
    chmod 644 ~/.ssh/"${key_name}.pub"
    echo "Generated public key at ~/.ssh/${key_name}.pub"
  fi
done

echo "SSH key export complete"

# Update allowed_signers for GitHub keys
echo "Updating ~/.ssh/allowed_signers"
for i in "${!KEY_TYPES[@]}"; do
  key_type="${KEY_TYPES[$i]}"

  if [[ "${key_type}" == "github" ]]; then
    key_name="id_${mode}_${key_type}"
    public_key_content=$(cat ~/.ssh/"${key_name}.pub")

    # Create or update allowed_signers
    allowed_signers=~/.ssh/allowed_signers

    # Remove any existing entries for this email
    if [[ -f "${allowed_signers}" ]]; then
      grep -v "^${EMAIL}" "${allowed_signers}" > "${allowed_signers}.tmp" || true
      mv "${allowed_signers}.tmp" "${allowed_signers}"
    fi

    # Add new entry
    echo "${EMAIL} ${public_key_content}" >> "${allowed_signers}"
    echo "Added ${EMAIL} to allowed_signers"
  fi
done

# Update SSH config
if [[ -f ~/.ssh/config ]]; then
  echo "Updating ~/.ssh/config"

  for i in "${!KEY_TYPES[@]}"; do
    key_type="${KEY_TYPES[$i]}"
    key_name="id_${mode}_${key_type}"

    # Map key types to host entries
    case "${key_type}" in
      github)
        host="github.com"
        ;;
      *)
        echo "Warning: No host mapping for key type '${key_type}'"
        continue
        ;;
    esac

    # Update IdentityFile for this host
    if grep -q "^Host ${host}" ~/.ssh/config; then
      sed -i.bak "/^Host ${host}/,/^Host / s|IdentityFile.*|IdentityFile ~/.ssh/${key_name}|" ~/.ssh/config
      echo "Updated IdentityFile for ${host} to ~/.ssh/${key_name}"
    else
      echo "Warning: Host ${host} not found in ~/.ssh/config"
    fi
  done

  # Remove backup file
  rm -f ~/.ssh/config.bak
else
  echo "Warning: ~/.ssh/config not found, skipping config update"
fi

echo "Setup complete"

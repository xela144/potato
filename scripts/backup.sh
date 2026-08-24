#!/usr/bin/env bash

# Encrypted, deduplicated backup of keys/creds/history/media to a restic
# repo that lives inside the Nextcloud sync folder -- the Nextcloud desktop
# client handles the actual upload, restic just handles encryption + dedup.
#
# One-time setup before first run:
#   mkdir -p ~/.config/restic
#   openssl rand -base64 32 > ~/.config/restic/password
#   chmod 600 ~/.config/restic/password
#   Save that password in KeePassXC -- it's the only way to decrypt this
#   backup from a different machine.

set -euo pipefail

RESTIC_REPO="$HOME/Nextcloud/backups/restic-repo"
PASSWORD_FILE="$HOME/.config/restic/password"

SOURCES=(
  "$HOME/.ssh"
  "$HOME/.aws"
  "$HOME/.bash_unlimited_history"
  "$HOME/Videos"
  "$HOME/Downloads"
  "$HOME/Pictures"
  "$HOME/tmp"
  "$HOME/code"
)

if [[ ! -f "$PASSWORD_FILE" ]]; then
  echo "Missing $PASSWORD_FILE -- see setup instructions at the top of this script." >&2
  exit 1
fi

export RESTIC_REPOSITORY="$RESTIC_REPO"
export RESTIC_PASSWORD_FILE="$PASSWORD_FILE"

if ! restic snapshots >/dev/null 2>&1; then
  mkdir -p "$RESTIC_REPO"
  restic init
fi

restic backup "${SOURCES[@]}"
restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune

#!/usr/bin/env bash

# Backup of keys/creds/history/media into a timestamped tarball dropped in
# the Nextcloud sync folder -- the Nextcloud desktop client handles the
# actual upload.
#
# Not encrypted. This is fine as long as the machine disk and the Nextcloud
# account are both trusted; revisit with restic (already in
# nix/userland.nix) if that stops being true.

set -euo pipefail

DEST_DIR="$HOME/Nextcloud/backups"
STAMP="$(date +%Y%m%d-%H%M%S)"
ARCHIVE="$DEST_DIR/potato-backup-$STAMP.tar.gz"

SOURCES=(
  ".ssh"
  ".aws"
  ".bash_unlimited_history"
  "Videos"
  "Downloads"
  "Pictures"
  "tmp"
  "code"
)

EXCLUDES=(
  ".git"
  "node_modules"
  ".venv"
  "venv"
  "__pycache__"
  "*.pyc"
  ".tox"
  ".mypy_cache"
  ".pytest_cache"
  "target"
  ".next"
  "dist"
  "build"
)

mkdir -p "$DEST_DIR"

TAR_EXCLUDE_ARGS=()
for pattern in "${EXCLUDES[@]}"; do
  TAR_EXCLUDE_ARGS+=(--exclude="$pattern")
done

tar -czf "$ARCHIVE" "${TAR_EXCLUDE_ARGS[@]}" -C "$HOME" "${SOURCES[@]}"

echo "Wrote $ARCHIVE"

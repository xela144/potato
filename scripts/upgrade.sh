#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

UPGRADE_NIX=false
UPGRADE_PACMAN=false
UPGRADE_FLATPAK=false

if [[ $# -eq 0 ]]; then
  UPGRADE_NIX=true
  UPGRADE_PACMAN=true
  UPGRADE_FLATPAK=true
else
  for arg in "$@"; do
    case "$arg" in
      nix)     UPGRADE_NIX=true ;;
      pacman)  UPGRADE_PACMAN=true ;;
      flatpak) UPGRADE_FLATPAK=true ;;
      *) echo "Unknown argument: $arg"; echo "Usage: $0 [nix] [pacman] [flatpak]"; exit 1 ;;
    esac
  done
fi

if $UPGRADE_PACMAN; then
  echo "==> Upgrading system packages (pacman)..."
  sudo pacman -Syu
fi

if $UPGRADE_NIX; then
  echo "==> Updating nix flake inputs..."
  nix flake update "$ROOT"
  echo "==> Reinstalling nix profile..."
  "$ROOT/scripts/sync.sh"
fi

if $UPGRADE_FLATPAK; then
  echo "==> Upgrading flatpaks..."
  flatpak update -y
fi

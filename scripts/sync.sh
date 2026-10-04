#!/usr/bin/env bash

# Ensure that declared packages are present on the machine. Does not do
# a package upgrade for any installed packages.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Upgrade in place so a failed or interrupted run leaves the current
# userland installed instead of removing it first.
if nix profile list --json | grep -q '"userland":'; then
  nix profile upgrade userland
else
  nix profile add "$ROOT#userland"
fi

"$ROOT/scripts/link.sh"

if [[ -s "$ROOT/apps/arch-pacman.txt" ]]; then
  mapfile -t PKGS < <(grep -vE '^\s*#|^\s*$' "$ROOT/apps/arch-pacman.txt")
  [[ ${#PKGS[@]} -gt 0 ]] && sudo pacman -S --needed "${PKGS[@]}"
fi

if [[ -s "$ROOT/apps/flatpak.txt" ]]; then
  mapfile -t FLATPAKS < <(grep -vE '^\s*#|^\s*$' "$ROOT/apps/flatpak.txt")
  [[ ${#FLATPAKS[@]} -gt 0 ]] && flatpak install -y flathub "${FLATPAKS[@]}"
fi

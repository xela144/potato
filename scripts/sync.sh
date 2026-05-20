#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

nix profile remove userland 2>/dev/null || true
nix profile install "$ROOT#userland"

"$ROOT/scripts/link.sh"

if [[ -s "$ROOT/apps/arch-pacman.txt" ]]; then
  mapfile -t PKGS < <(grep -vE '^\s*#|^\s*$' "$ROOT/apps/arch-pacman.txt")
  [[ ${#PKGS[@]} -gt 0 ]] && sudo pacman -S --needed "${PKGS[@]}"
fi

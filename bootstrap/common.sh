#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

git config --global user.name "xela144"
git config --global user.email "alex.d.bardales@gmail.com"
git config --global core.editor nvim

if ! command -v nix &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
fi

mapfile -t FLATPAKS < <(grep -vE '^\s*#|^\s*$' "$ROOT/apps/flatpak.txt")
[[ ${#FLATPAKS[@]} -gt 0 ]] && flatpak install -y flathub "${FLATPAKS[@]}"

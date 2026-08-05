#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mapfile -t FLATPAKS < <(grep -vE '^\s*#|^\s*$' "$ROOT/apps/flatpak.txt")
[[ ${#FLATPAKS[@]} -gt 0 ]] && flatpak install -y flathub "${FLATPAKS[@]}"

#!/usr/bin/env bash
set -euo pipefail

git config --global user.name "xela144"
git config --global user.email "alex.d.bardales@gmail.com"
git config --global core.editor nvim

if ! command -v nix &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
fi

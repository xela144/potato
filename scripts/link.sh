#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$HOME/.config"
ln -snf "$ROOT/config/bash/.bashrc"   "$HOME/.bashrc"
ln -snf "$ROOT/config/direnv"         "$HOME/.config/direnv"
ln -snf "$ROOT/config/ghostty"        "$HOME/.config/ghostty"
ln -snf "$ROOT/config/nvim"           "$HOME/.config/nvim"
ln -snf "$ROOT/config/stylua"         "$HOME/.config/stylua"
ln -snf "$ROOT/config/tmux/tmux.conf" "$HOME/.tmux.conf"

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
ln -snf "$ROOT/config/ssh/config" "$HOME/.ssh/config"
chmod 600 "$HOME/.ssh/config"

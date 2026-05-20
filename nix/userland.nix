{ pkgs }:
with pkgs; [
  # editor
  neovim

  # terminal multiplexer
  tmux
  xclip

  # shell tools
  less
  ripgrep
  fd
  fzf
  jq
  bat
  eza
  direnv

  # lang: python
  uv

  # lang: js/ts (node version managed by nvm)
  pnpm
  bun

  # lang: go
  go

  # nix
  nil
  devbox
]

{ pkgs, pkgs-unstable, hunk-pkg }:
with pkgs; [
  # editor
  pkgs-unstable.neovim

  # terminal multiplexer
  tmux
  xclip

  # shell tools
  bat
  direnv
  eza
  fd
  fzf
  hunk-pkg
  jq
  lazygit
  less
  ripgrep
  tldr

  # languages
  go
  uv

  # js/ts
  bun
  nodePackages.typescript-language-server
  pnpm
  pyright
  tailwindcss-language-server

  # nix
  devbox
  nil

  # lua/nvim
  luarocks
  stylua
  tree-sitter
]

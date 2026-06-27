{ pkgs, pkgs-unstable, hunk-pkg }:
with pkgs; [
  # editor
  pkgs-unstable.neovim

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
  lazygit
  hunk-pkg
  tldr

  # lang: python
  uv

  # lang: js/ts (node version managed by nvm)
  pnpm
  bun
  nodePackages.typescript-language-server
  tailwindcss-language-server
  pyright

  # lang: go
  go

  # nix
  nil
  devbox

  # nvim support
  luarocks
  stylua
  tree-sitter
]

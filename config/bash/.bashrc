# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$HOME/.nix-profile/share/nvm/init-nvm.sh" ] && source "$HOME/.nix-profile/share/nvm/init-nvm.sh"

# direnv
command -v direnv &>/dev/null && eval "$(direnv hook bash)"

export PATH="$PATH:$HOME/.local/bin/"

# history
export HISTFILESIZE=-1
export HISTSIZE=-1
export HISTTIMEFORMAT="[%F-%T] "
export HISTFILE=~/.bash_unlimited_history
export HISTCONTROL=ignorespace
shopt -s histappend

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$HOME/.nix-profile/share/nvm/init-nvm.sh" ] && source "$HOME/.nix-profile/share/nvm/init-nvm.sh"

# eza (aka better ls)
alias ls='eza'
alias ll='eza -la'
alias la='eza -a'
alias lt='eza --tree'

# fzf
source ~/.nix-profile/share/fzf/key-bindings.bash
source ~/.nix-profile/share/fzf/completion.bash

# direnv
command -v direnv &>/dev/null && eval "$(direnv hook bash)"

# PS1
parse_git_branch() { git branch --show-current 2>/dev/null; }

PS1='\[\e[1;35m\][\u@\h \[\e[1;34m\]\W\[\e[0;36m\]$(b=$(parse_git_branch); [ -n "$b" ] && echo " ($b)")\[\e[1;35m\]]\$\[\e[0m\] '

set -o vi


export PATH="$PATH:$HOME/.local/bin/"

# machine-local config (not tracked in repo)
[ -f ~/.bash_local ] && source ~/.bash_local

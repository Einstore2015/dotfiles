#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias ll='lsd -alF'
alias grep='grep --color=auto'

PS1='[\u@\h \W]\$ '

# Oh-My-Posh Config
# eval "$(starship init bash)"
eval "$(oh-my-posh init bash --config $HOME/.config/ohmyposh/xero.omp.json)"

. "$HOME/.local/bin/env"
. "$HOME/.cargo/env"

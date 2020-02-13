#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
# environment variables
export LANG=ja_JP,UTF-8

# colors
autoload -Uz colors
colors

## ZSH_SYNTAX_HIGHLIGHTING
ZSH_HIGHLIGHT_STYLES[alias]=fg=green,underline


# settings


alias ez='nvr ~/.zshrc'
alias ev='nvr ~/.config/nvim/init.vim'
alias sz='source ~/.zshrc'
alias lsa='ls -a'

alias h='cd $HOME'

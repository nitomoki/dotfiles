#
# Executes commands at the start of an interactive session.
#
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
# environment variables
export LANG=ja_JP.UTF-8

# colors
autoload -Uz colors
colors

## ZSH_SYNTAX_HIGHLIGHTING
ZSH_HIGHLIGHT_STYLES[alias]=fg=green,underline
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=238'

# PATH
export PATH=$PATH:$HOME/.local/bin/:$HOME/dotfiles/bin/:$HOME/.cargo/bin/

# settings
#
# bindkey
bindkey '^K' autosuggest-accept
# ros settings ={
ros_catkin_dir=~/catkin_ws
if [ -e $ros_catkin_dir ]; then
    source $ros_catkin_dir/devel/setup.zsh
fi
# } 

alias ez='nvr ~/.zshrc'
alias ev='nvr ~/.config/nvim/init.vim'
alias sz='source ~/.zshrc'
alias lsa='ls -A'
alias h='cd $HOME'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias grep='grep --color=auto'
alias bat='upower -i /org/freedesktop/UPower/devices/battery_BAT1'

# alias ghci='stack ghci'
# alias ghc='stack ghc'




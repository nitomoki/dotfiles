#
# Executes commands at the start of an interactive session.
#
#

# Source Prezto.
#if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
#    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
#    ZSH_HIGHLIGHT_STYLES[alias]=fg=green,underline
#    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=238'
#fi

DOTFILES_DIR=$HOME/dotfiles

# Customize to your needs...
# environment variables
export LANG=ja_JP.UTF-8

# colors
autoload -Uz colors && colors

## ZSH_SYNTAX_HIGHLIGHTING

# PATH
export PATH=$PATH:$HOME/.local/bin/:$HOME/dotfiles/bin/:$HOME/.cargo/bin/

# source local zsh setting
if [ ! -f ~/.zshrc.local ]; then
    touch ~/.zshrc.local
fi
source ~/.zshrc.local


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



autoload -Uz add-zsh-hook
if [[ -n "$VIM_TERMINAL" ]]; then
  add-zsh-hook -Uz chpwd cdv
  cdv() {
    printf -- '\033]51;["call", "Tapi_lcd", "%q"]\007' "$(pwd)"
  }
elif [[ -n "$NVIM_LISTEN_ADDRESS" ]]; then
  add-zsh-hook -Uz chpwd cdv
  cdv() {
    nvr --servername "$VIM_SERVERNAME" --remote-expr "$(printf -- 'Tapi_lcd(0, "%q")' "$(pwd)")"
  }
fi



##########zinit installer##########
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit


source $DOTFILES_DIR/zsh/alias.zsh
source $DOTFILES_DIR/zsh/config.zsh
source $DOTFILES_DIR/zsh/plugins.zsh

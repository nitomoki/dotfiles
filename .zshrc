if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source Prezto.
#if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
#    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
#    ZSH_HIGHLIGHT_STYLES[alias]=fg=green,underline
#    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=238'
#fi

DOTFILES_DIR=$HOME/dotfiles

export LANG=ja_JP.UTF-8
export PATH=$PATH:$HOME/.local/bin/:$HOME/dotfiles/bin/:$HOME/.cargo/bin/

# source local zsh setting
if [ ! -f ~/.zshrc.local ]; then
    touch ~/.zshrc.local
fi
source ~/.zshrc.local


# ros settings ={
ros_catkin_dir=~/catkin_ws
if [ -e $ros_catkin_dir ]; then
    source $ros_catkin_dir/devel/setup.zsh
fi
# } 




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
source $DOTFILES_DIR/zsh/extract.zsh


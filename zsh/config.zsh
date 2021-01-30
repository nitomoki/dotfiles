##########Vim & Nvim terminal cd##########
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


autoload -Uz colors && colors
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

export HISTFILE=$HOME/dotfiles/zsh/.zsh_history
export HISTSIZE=100000
export SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt hist_ignore_dups

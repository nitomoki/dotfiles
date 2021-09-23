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
#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}'


export HISTFILE=$HOME/.zsh_history
export HISTSIZE=1000000
export SAVEHIST=1000000
setopt EXTENDED_HISTORY
setopt hist_reduce_blanks
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt share_history
setopt hist_find_no_dups
setopt hist_no_store
zshaddhistory() {
    local line=${1%%$'\n'}
    local cmd=${line%% *}
    [[ ${#line} -ge 5
        && ${cmd} != (l|l[sal])
        && ${cmd} != (cd)
        && ${cmd} != (m|man)
        && ${cmd} != (r[mr])
    ]]
}

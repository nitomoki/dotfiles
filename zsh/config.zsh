autoload -Uz add-zsh-hook

autoload -Uz colors && colors
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}'
#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

bindkey '^k' autosuggest-accept
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)

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
setopt no_flow_control
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

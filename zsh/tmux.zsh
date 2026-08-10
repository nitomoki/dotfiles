# tmux セッション操作
#
# このファイルは alias.zsh ではなく独立させている。compdef は compinit の後で
# ないと使えず、sheldon は zsh/*.zsh をアルファベット順に読むため、
# config.zsh（compinit を実行する）より後ろに来る名前である必要があるため。

alias tl="tmux ls"
alias ta="tmux attach -t"
alias tbit="tmux new -A -s bitburner -d 'cd ~/bitburner-scripts && npm run dev'"
alias tnvim="tmux new -A -s neovim"

# tc <name> / t <name> : そのセッションへ移動（無ければ作成）
#   tmux の中から呼べば switch-client、外から呼べば attach する。
#   引数は TAB で補完できる（起動中のセッション + tmux-sessionizer のプリセット）。
# tc  : 引数なしは従来どおり shell セッション
# t   : 引数なしは fzf のピッカー
tc() {
    tmux-sessionizer switch "${1:-shell}"
}

t() {
    if (( $# )); then
        tmux-sessionizer switch "$1"
    else
        tmux-sessionizer
    fi
}

# セッション名の補完。起動中のものを先に、未起動のプリセットを後ろに出す。
_tmux_session_names() {
    local -a running presets stopped
    running=(${(f)"$(command tmux list-sessions -F '#S' 2>/dev/null)"})
    presets=(${(f)"$(command tmux-sessionizer list 2>/dev/null)"})
    stopped=(${presets:|running})

    _describe -t sessions '起動中のセッション' running
    _describe -t presets  'プリセット (未起動)' stopped
}

# 起動中のセッションのみ（attach は既存セッションにしか繋げないため）
_tmux_running_sessions() {
    local -a running
    running=(${(f)"$(command tmux list-sessions -F '#S' 2>/dev/null)"})
    _describe -t sessions '起動中のセッション' running
}

compdef _tmux_session_names tc t
compdef _tmux_running_sessions ta

alias h='cd $HOME'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias grep='grep --color=auto'
alias gcm='git commit -m'
alias gs='git status'
alias gp='git push'
alias gl='git log --graph --oneline --decorate --all'
alias dof='cd ~/dotfiles'

case "${OSTYPE}" in
darwin*)
    if type exa > /dev/null 2>&1; then
        alias ls="exa -h"
        alias lsa="ls -aF"
        alias ll="ls -lF"
        alias lla="ls -laF"
    else
        alias ls="ls -G"
        alias ll="ls -lG"
        alias la="ls -laG"
    fi
    ;;
linux*)
    alias ls='ls -F --color'
    alias lsa='ls -aF --color'
    alias ll="ls -lhF --color"
    alias lla="ls -alhF --color"
    ;;
esac


if type bat > /dev/null 2>&1; then
    alias cat="bat"
fi


if [ "`uname -r |grep 'arch'`" ]; then
    alias pac='sudo pacman -S --noconfirm'
    alias pacu='sudo pacman -Syu --noconfirm'
    alias pacr='sudo pacman -Rs'
    alias pacs='pacman -Ss'
    alias paci='pacman -Si'
    alias paclf='pacman -Ql'
fi


# neovim remote
if type nvr > /dev/null 2>&1; then
    alias nvro="nvr -cc q "
    alias nvrcd='pwd | xargs -I{} nvr -cc "cd {}"'
fi

# tmux
alias tc="tmux new -A -s claude"
alias tl="tmux ls"
alias ta="tmux attach -t"
alias tbit="tmux new -A -s bitburner -d 'cd ~/bitburner-scripts && npm run dev'"
alias tnvim="tmux new -A -s neovim"
alias nbc='if command -v mosh >/dev/null 2>&1; then mosh nucbox -- tmux new -A -s claude; else autossh -M 0 -o "ServerAliveInterval 60" -o "ServerAliveCountMax 3" nucbox -t "tmux new -A -s claude"; fi'

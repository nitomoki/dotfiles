alias ez='nvr ~/.zshrc'
alias ev='nvr ~/.config/nvim/init.vim'
alias sz='source ~/.zshrc'
alias ls='ls --color'
alias lsa='ls -A'
alias h='cd $HOME'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias grep='grep --color=auto'
alias gcm='git commit -m'
alias gs='git status'
alias gp='git push'
alias gl='git log --graph --oneline --decorate --all'
alias dotfiles='cd ~/dotfiles'
#alias bat='upower -i /org/freedesktop/UPower/devices/battery_BAT1'

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

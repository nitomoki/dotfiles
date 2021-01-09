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
#alias bat='upower -i /org/freedesktop/UPower/devices/battery_BAT1'

if builtin command -v bat > /dev/null; then
  alias cat="bat"
fi

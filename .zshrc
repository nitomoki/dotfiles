if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

DOTFILES_DIR=$HOME/dotfiles

export LANG=ja_JP.UTF-8
export PATH=$PATH:$HOME/.local/bin/:$HOME/dotfiles/bin/:$HOME/.cargo/bin/

# source local zsh setting
if [ ! -f ~/.zshrc.local ]; then
    touch ~/.zshrc.local
fi
source ~/.zshrc.local


if ! type sheldon > /dev/null; then
    echo "install sheldon!"
    curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
    mkdir -p ~/.local/share/sheldon/
fi

eval "$(sheldon source)"
source $DOTFILES_DIR/zsh/alias.zsh
source $DOTFILES_DIR/zsh/config.zsh
source $DOTFILES_DIR/zsh/extract.zsh


alias luamake=/home/tomoki/.cache/nvim/lspconfig/sumneko_lua/lua-language-server/3rd/luamake/luamake

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

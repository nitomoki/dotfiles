DOTFILES_DIR=$HOME/dotfiles

export LANG=ja_JP.UTF-8
export PATH=$PATH:$HOME/.local/bin/:$HOME/dotfiles/bin/:$HOME/.cargo/bin/:/usr/local/bin/
export XDG_CONFIG_HOME=$HOME/.config/

# Deno config
export DENO_INSTALL="/home/tomoki/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

if ! type sheldon > /dev/null 2>&1; then
    echo "install sheldon!"
    curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
    mkdir -p ~/.local/share/sheldon/
fi
eval "$(sheldon source)"

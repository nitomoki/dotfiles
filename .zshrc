DOTFILES_DIR=$HOME/dotfiles

# PATH と環境変数は .zshenv で組む。pnpm setup や uv のインストーラは PATH の
# 設定をこのファイルに追記してくるので、追記されたら消す。

if ! type sheldon > /dev/null 2>&1; then
    echo "install sheldon!"
    curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
    mkdir -p ~/.local/share/sheldon/
fi
eval "$(sheldon source)"

# path の -U は配列 path への代入でしか効かず、プラグインが使う PATH=… の
# 形では重複が残る。最後に配列として代入し直して除く。
path=($path)

# zsh が対話・非対話を問わず必ず読むファイル。PATH と環境変数はここでだけ組む。
# .zshrc に置くと、非対話の ssh（リモートの mosh-server 起動など）や `zsh -lc` では
# 読まれず、~/.local/bin などが PATH に入らない。
# zsh のスクリプトも毎回これを読むので、何かを出力する処理や重い処理は置かない。

export LANG=ja_JP.UTF-8
export XDG_CONFIG_HOME=$HOME/.config/
export DENO_INSTALL=$HOME/.deno
export PNPM_HOME=$HOME/.local/share/pnpm

# -U は重複を除き、先に出た方を残す。入れ子の zsh で組み直しても増えず、
# ~/.profile（Ubuntu の GUI ログインで読まれる）が別の順で足していても
# ここで並べた順になる。効くのは配列 path への代入だけで、PATH=… では効かない
# （.zshrc の末尾で組み直しているのはそのため）。
typeset -gU path

# Nix のインストーラが書き込むのは /etc/zshrc などで、ssh 先の非対話 zsh -c は読まない。
# Ubuntu の zsh は /etc/zsh/ 以下しか読まないので、対話シェルでも読まれないことがある。
# ここで読めば、どこから起動しても nix と home-manager で入れたものが使える。
# 中身は環境変数を足すだけで、二重読み込みは自前の変数で防いでいる。
if [[ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# macOS のログインシェルでは /etc/zprofile の path_helper が .zshenv の後に動き、
# /usr/bin などを先頭へ並べ直し、~/.zprofile の brew shellenv が /opt/homebrew/bin を
# ~/.local/bin より前に入れる。そのため .zlogin からもう一度呼ぶ。.zlogin は
# ログインシェルなら `zsh -lc` でも読まれ、~/.zprofile より後に動く（.zshrc は
# `zsh -lc` では読まれない）。~/.zprofile で呼ばないのは、そこが brew の
# shellenv を書くマシンごとのファイルで、dotfiles から symlink すると消してしまうため。
# (N-/) は「存在するディレクトリなら残す」修飾子。無いマシンで PATH を汚さない。
dotfiles_path() {
    path=(
        $HOME/.local/bin      # 自前スクリプトで入れたもの（mosh フォーク等）。apt / brew 版より先に引く
        $HOME/dotfiles/bin
        $HOME/.cargo/bin(N-/) # rustup。apt / brew の cargo より先に引く
        $PNPM_HOME(N-/)
        $DENO_INSTALL/bin(N-/)
        $HOME/.nix-profile/bin(N-/)              # home-manager。brew / apt 版より先に引く
        /nix/var/nix/profiles/default/bin(N-/)   # nix コマンド本体
        /opt/homebrew/bin(N-/)
        /opt/homebrew/sbin(N-/)
        $path
    )
}
dotfiles_path

#!/bin/bash
# Linux (Ubuntu) の OS 側の設定のうち、home-manager では扱えないもの（root 権限で
# システムを書き換えるもの）。make setup から呼ぶ。何度実行してもよい。
set -euo pipefail

cd "$(dirname "$0")/.."

# --- apt パッケージ（packages.txt） ---
if grep -q 'Ubuntu' /etc/os-release; then
    mapfile -t packages < <(grep -vE '^\s*(#|$)' packages.txt)
    sudo apt update -y
    sudo apt install -y "${packages[@]}"
    sudo apt upgrade -y
    sudo apt autoremove -y
else
    echo "Ubuntu ではないので apt のパッケージは入れない。"
fi

# --- ログインシェルを zsh に（zsh は packages.txt の apt で入る） ---
# /etc/passwd ではなくログインシェル ($SHELL) で判定する（macOS 版と揃える）。
case "$SHELL" in
    */zsh) ;;
    *) chsh -s "$(command -v zsh)" ;;
esac

# --- ファイアウォール：mosh / ssh を外から届くようにする ---
# mosh はアプリケーションルール（`ufw allow mosh`）ではなくポートで開ける。
# アプリケーションルールの定義は apt の mosh が入れるファイルにあり、
# Nix で入れたカスタム版だけのマシンには無いため。範囲は mosh-server の既定。
if command -v ufw >/dev/null; then
    sudo ufw allow ssh
    sudo ufw allow 60000:61000/udp comment 'mosh'
else
    echo "ufw が無いのでファイアウォールの設定は飛ばす。"
fi

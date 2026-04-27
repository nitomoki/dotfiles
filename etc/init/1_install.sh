#!/bin/bash
# packages.txt をもとに apt パッケージをインストール。
# 一覧の編集は dotfiles リポジトリの packages.txt で行う。
set -e

PACKAGES_FILE="$(dirname "$0")/../../packages.txt"

if [ ! -f "$PACKAGES_FILE" ]; then
    echo "packages.txt not found at $PACKAGES_FILE" >&2
    exit 1
fi

# コメント / 空行を除外して 1 行 1 パッケージに整形
mapfile -t packages < <(grep -vE '^\s*(#|$)' "$PACKAGES_FILE")

if grep -q 'Ubuntu' /etc/os-release; then
    sudo apt update -y
    sudo apt install -y "${packages[@]}"
    sudo apt upgrade -y
    sudo apt autoremove -y
else
    echo "Non-Ubuntu environment; skipping apt install."
fi

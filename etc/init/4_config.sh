#!/bin/bash

git config --get --global user.name | grep -q nitomoki
if [ "$?" -ne 0 ]; then
    git config --global user.email "nitomoki.2@gmail.com"
    git config --global user.name "nitomoki"
fi

# ログインシェルが zsh でなければ切り替える。/etc/passwd は macOS ではユーザ情報の
# 実体ではない (Directory Services 管理) ので、ログインシェル ($SHELL) で判定する。
case "$SHELL" in
    */zsh) ;;
    *) chsh -s "$(command -v zsh)" ;;
esac

#!/bin/bash
# ログインシェルの変更は /etc/shells と OS のユーザー情報を書き換えるので、home-manager
# では扱えない。

# ログインシェルが zsh でなければ切り替える。/etc/passwd は macOS ではユーザ情報の
# 実体ではない (Directory Services 管理) ので、ログインシェル ($SHELL) で判定する。
case "$SHELL" in
    */zsh) ;;
    *) chsh -s "$(command -v zsh)" ;;
esac

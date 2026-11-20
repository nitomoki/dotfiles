#!/bin/bash
# macOS の OS 側の設定のうち、nix-darwin / home-manager で扱わないもの。make setup から
# 呼ぶ。何度実行してもよい。
set -euo pipefail

# --- ログインシェルを zsh に ---
# /etc/passwd は macOS ではユーザ情報の実体ではない (Directory Services 管理) ので、
# ログインシェル ($SHELL) で判定する。nix-darwin の users.users.<name>.shell は
# users.knownUsers に入れたユーザーにしか効かず、入れると nix-darwin がユーザーの
# 作成・削除まで管理するので使わない。
case "$SHELL" in
    */zsh) ;;
    *) chsh -s "$(command -v zsh)" ;;
esac

# --- Ctrl+Space を tmux の prefix に渡す ---
# macOS 既定の「前の入力ソースを選択」(ID 60) が C-Space を WezTerm に届く前に奪う。
# 入力ソースの切り替えは 英数 / かな キーか Ctrl+Option+Space (ID 61) で行う。
# nix-darwin の system.defaults.CustomUserPreferences は defaults write で
# AppleSymbolicHotKeys の辞書全体を置き換え、他のショートカット設定を消すので使わない。
# activateSettings -u で再ログインせずに反映する。
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:60:enabled false" \
    "$HOME/Library/Preferences/com.apple.symbolichotkeys.plist"
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
echo "Ctrl+Space (前の入力ソースを選択) を無効にした"

#!/bin/bash
# 新マシンで mosh / ssh が外から到達できるようにする。
# mosh はアプリケーションルール（`ufw allow mosh`）ではなくポートで開ける。
# アプリケーションルールの定義は apt の mosh が入れるファイルにあり、
# ~/.local のカスタム版だけのマシンには無いため。範囲は mosh-server の既定。
set -e

if ! command -v ufw >/dev/null; then
    echo "ufw not installed; skipping."
    exit 0
fi

sudo ufw allow ssh
sudo ufw allow 60000:61000/udp comment 'mosh'

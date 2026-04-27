#!/bin/bash
# ufw のアプリケーションルールを有効化。
# 新マシンで mosh / ssh が外から到達できるようにする。
set -e

if ! command -v ufw >/dev/null; then
    echo "ufw not installed; skipping."
    exit 0
fi

sudo ufw allow ssh
sudo ufw allow mosh

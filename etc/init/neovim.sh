#!/bin/bash
# Neovim を GitHub からソースビルドして apt 管理可能な .deb としてインストール。
# https://github.com/neovim/neovim/blob/master/BUILD.md
#
# 環境変数:
#   NVIM_REF   ブランチ / タグ名 (default: master)
#
# アンインストール:
#   sudo apt remove neovim
set -euo pipefail

REF="${NVIM_REF:-master}"

# ビルド依存 (公式 BUILD.md の最小セット)
sudo apt update -y
sudo apt install -y ninja-build gettext cmake curl build-essential git

# cpack の命名規則に合わせてアーキテクチャを判定
case "$(uname -m)" in
    x86_64)  ARCH=x86_64 ;;
    aarch64) ARCH=arm64 ;;
    *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

# 一時ディレクトリでビルド (失敗時／正常終了時とも自動削除)
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

git clone --depth 1 --branch "$REF" https://github.com/neovim/neovim "$WORKDIR/neovim"
cd "$WORKDIR/neovim"

make CMAKE_BUILD_TYPE=RelWithDebInfo

# .deb を作って dpkg でインストール (sudo make install より apt 連携が綺麗)
cd build
cpack -G DEB
sudo dpkg -i "nvim-linux-${ARCH}.deb"

echo ""
echo "Installed: $(nvim --version | head -1)"

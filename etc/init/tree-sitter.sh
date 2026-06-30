#!/bin/bash
# tree-sitter CLI を GitHub のプリビルド静的バイナリでインストール。
# nvim-treesitter の main ブランチは parser を `tree-sitter build` でビルドするため
# この CLI が必須 (master ブランチは同梱 parser.c を cc で直接コンパイルし不要だった)。
# 要件: tree-sitter-cli 0.26.1 以降 (npm 版は不可)。
# https://github.com/tree-sitter/tree-sitter
#
# 環境変数:
#   TREE_SITTER_VERSION  リリースタグ (default: 最新リリースを解決)
#   PREFIX               インストール先ディレクトリ (default: $HOME/.local/bin)
#
# アンインストール:
#   rm -f ~/.local/bin/tree-sitter
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local/bin}"

# リリースアセットの命名 (tree-sitter-linux-<arch>.gz) に合わせてアーチを判定
case "$(uname -m)" in
    x86_64)  ARCH=x64 ;;
    aarch64) ARCH=arm64 ;;
    *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

# バージョン解決 (未指定なら最新リリースのタグを取得)
VERSION="${TREE_SITTER_VERSION:-}"
if [ -z "$VERSION" ]; then
    VERSION="$(curl -fsSL https://api.github.com/repos/tree-sitter/tree-sitter/releases/latest \
        | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')"
fi
if [ -z "$VERSION" ]; then
    echo "Failed to resolve tree-sitter release version" >&2
    exit 1
fi

ASSET="tree-sitter-linux-${ARCH}.gz"
URL="https://github.com/tree-sitter/tree-sitter/releases/download/${VERSION}/${ASSET}"

# 一時ディレクトリで展開 (失敗時／正常終了時とも自動削除)
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

echo "Downloading ${ASSET} (${VERSION}) ..."
curl -fSL -o "$WORKDIR/tree-sitter.gz" "$URL"
gunzip "$WORKDIR/tree-sitter.gz"        # -> $WORKDIR/tree-sitter
chmod +x "$WORKDIR/tree-sitter"

mkdir -p "$PREFIX"
mv -f "$WORKDIR/tree-sitter" "$PREFIX/tree-sitter"

echo ""
echo "Installed: $("$PREFIX/tree-sitter" --version)  ->  $PREFIX/tree-sitter"

# PATH 未登録なら警告 (nvim から tree-sitter を呼べるように)
case ":$PATH:" in
    *":$PREFIX:"*) ;;
    *) echo "NOTE: $PREFIX が \$PATH に無い。シェル設定に追加して下さい。" >&2 ;;
esac

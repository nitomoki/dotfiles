#!/bin/bash
# 私用フォークの markdown-reader（nitomoki/markdown-reader の Release にあるビルド済み
# バイナリ）を PREFIX に入れる。入れられなかったときは、その理由を出してから、
# フォークを cargo install でビルドする（cargo があり、markdown-reader がまだ無いときだけ）。
# https://github.com/nitomoki/markdown-reader/releases
#
# 再実行すると最新リリースに更新する。導入済みなら何もしない。
#
# 環境変数:
#   MARKDOWN_READER_VERSION  リリースタグ (default: 最新リリースを解決)
#   PREFIX                   インストール先 (default: $HOME/.local)。bin/ に置く
#
# ~/.local/bin は .zshrc で ~/.cargo/bin より前にあるので、cargo install で入れた
# 古いものが残っていてもこちらが使われる。
#
# アンインストール:
#   rm -f ~/.local/bin/markdown-reader
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
REPO=nitomoki/markdown-reader
BIN=bin/markdown-reader

os="$(uname -s)"

info() { echo "$*"; }
warn() { echo "$*" >&2; }

# --version が `markdown-reader 1.35.3 [build fork-1]` の形になる（フォークの build.rs）。
# 起動できるかの確認も兼ねる。
built_from() {
    local bin="$1" tag="$2" line
    line="$("$bin" --version 2>/dev/null | head -n1)" || return 1
    case "$line" in
        *"[build $tag]"*) return 0 ;;
        *) return 1 ;;
    esac
}

install_fallback() {
    if command -v markdown-reader >/dev/null 2>&1; then
        info "既にある markdown-reader を使う: $(command -v markdown-reader)"
        return 0
    fi
    if ! command -v cargo >/dev/null 2>&1; then
        warn "cargo が無いので markdown-reader をビルドできない。Rust を入れてから再実行すること。"
        return 1
    fi
    info "cargo install で $REPO をビルドする（数分かかる） ..."
    cargo install --locked --git "https://github.com/$REPO" markdown-tui-explorer
}

# 失敗したら理由を 1 行 stderr に出して非 0 を返す。PREFIX は元のままにする。
install_release() {
    local platform
    case "$os/$(uname -m)" in
        Linux/x86_64) platform=linux-x86_64 ;;
        Darwin/arm64) platform=macos-arm64 ;;
        *) warn "対象外の環境 ($os/$(uname -m)) なので、ビルド済みバイナリが無い"; return 1 ;;
    esac

    local tag="${MARKDOWN_READER_VERSION:-}"
    if [ -z "$tag" ]; then
        tag="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null \
            | sed -nE 's/.*"tag_name": *"([^"]+)".*/\1/p' | head -n1)" || true
    fi
    if [ -z "$tag" ]; then
        warn "最新リリースのタグを解決できない (リリースが無いか、GitHub API に届かないか、レート制限)"
        return 1
    fi

    if [ -x "$PREFIX/$BIN" ] && built_from "$PREFIX/$BIN" "$tag"; then
        info "markdown-reader ($tag) は導入済み: $PREFIX/bin"
        return 0
    fi

    # 作業場所を PREFIX の中に作るのは、最後の mv を同じファイルシステム内の rename にするため。
    # 起動中の markdown-reader の実行ファイルに上書きで書き込むと ETXTBSY で失敗するが、
    # rename で差し替えれば、動いているプロセスは古いファイルのまま続く。
    if ! mkdir -p "$PREFIX/bin" || ! WORKDIR="$(mktemp -d "$PREFIX/.markdown-reader-install.XXXXXX")"; then
        warn "$PREFIX に作業ディレクトリを作れない"
        return 1
    fi
    trap 'rm -rf "$WORKDIR"' EXIT

    local asset="markdown-reader-$tag-$platform.tar.gz"
    local base="https://github.com/$REPO/releases/download/$tag"
    info "Downloading $asset ($tag) ..."
    if ! curl -fsSL -o "$WORKDIR/$asset" "$base/$asset" \
        || ! curl -fsSL -o "$WORKDIR/SHA256SUMS" "$base/SHA256SUMS"; then
        warn "$tag の $asset か SHA256SUMS をダウンロードできない"
        return 1
    fi

    # SHA256SUMS には別プラットフォームのアセットも載っている。手元に無いファイルの行で
    # -c が失敗しないよう、対象の行だけを取り出して照合する（Mac の shasum には
    # --ignore-missing が無い版がある）。
    awk -v f="$asset" '$2 == f || $2 == "*" f' "$WORKDIR/SHA256SUMS" > "$WORKDIR/asset.sum"
    if ! [ -s "$WORKDIR/asset.sum" ]; then
        warn "SHA256SUMS に $asset の行が無い"
        return 1
    fi
    local sumcmd=(sha256sum)
    command -v sha256sum >/dev/null 2>&1 || sumcmd=(shasum -a 256)
    if ! (cd "$WORKDIR" && "${sumcmd[@]}" -c asset.sum >/dev/null); then
        warn "$asset のチェックサムが SHA256SUMS と合わない"
        return 1
    fi

    mkdir "$WORKDIR/new"
    if ! tar -xzf "$WORKDIR/$asset" --strip-components=1 -C "$WORKDIR/new"; then
        warn "$asset を展開できない"
        return 1
    fi
    if ! [ -f "$WORKDIR/new/$BIN" ]; then
        warn "$asset に $BIN が無い"
        return 1
    fi
    if ! built_from "$WORKDIR/new/$BIN" "$tag"; then
        warn "$asset の markdown-reader がこのマシンで起動できない"
        return 1
    fi

    # 既存のファイルは退避してから置く。置いたあとに動かなければ戻す。
    if [ -e "$PREFIX/$BIN" ]; then
        mv -f "$PREFIX/$BIN" "$WORKDIR/old"
    fi
    mv -f "$WORKDIR/new/$BIN" "$PREFIX/$BIN"
    if ! built_from "$PREFIX/$BIN" "$tag"; then
        rm -f "$PREFIX/$BIN"
        if [ -e "$WORKDIR/old" ]; then
            mv -f "$WORKDIR/old" "$PREFIX/$BIN"
        fi
        warn "置いた $PREFIX/$BIN が起動できないので、元に戻した"
        return 1
    fi

    info "Installed: $("$PREFIX/$BIN" --version 2>/dev/null | head -n1)  ->  $PREFIX/bin"
    case ":$PATH:" in
        *":$PREFIX/bin:"* | *":$PREFIX/bin/:"*) ;;
        *) warn "NOTE: $PREFIX/bin が \$PATH に無い。シェル設定に追加して下さい。" ;;
    esac
}

if install_release; then
    exit 0
fi

warn "ビルド済みの markdown-reader を入れられないので、cargo でビルドする。"
install_fallback

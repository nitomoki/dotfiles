#!/bin/bash
# カスタム版の mosh（nitomoki/mosh の Release にあるビルド済みバイナリ）を PREFIX に入れる。
# 入れられなかったときは、その理由を出してデフォルトの mosh（Linux は apt、Mac は brew）にする。
# https://github.com/nitomoki/mosh/releases
#
# 環境変数:
#   MOSH_VERSION  リリースタグ (default: 最新リリースを解決)
#   PREFIX        インストール先 (default: $HOME/.local)。bin/ と share/man/man1/ に置く
#
# PREFIX の既定が ~/.local なのは、~/.zshenv が ~/.local/bin を /usr/bin より先に
# PATH へ入れているため。手元の mosh もリモートの mosh-server も名前で引くだけで
# カスタム版になる（mosh-server は ssh 先の zsh -c が読む ~/.zshenv の PATH で引かれる）。
#
# アンインストール:
#   rm -f ~/.local/bin/mosh{,-client,-server} ~/.local/share/man/man1/mosh{,-client,-server}.1
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
REPO=nitomoki/mosh
FILES=(
    bin/mosh bin/mosh-client bin/mosh-server
    share/man/man1/mosh.1 share/man/man1/mosh-client.1 share/man/man1/mosh-server.1
)

os="$(uname -s)"

info() { echo "$*"; }
warn() { echo "$*" >&2; }

# --version の 1 行目が `mosh-client (mosh 1.4.0) [build fork-1]` の形になる。
# 起動できるかの確認も兼ねる。glibc が古いなど、このマシンで動かないバイナリはここで落ちる。
built_from() {
    local client="$1" tag="$2" line
    line="$("$client" --version 2>/dev/null | head -n1)" || return 1
    case "$line" in
        *"[build $tag]"*) return 0 ;;
        *) return 1 ;;
    esac
}

install_default() {
    case "$os" in
        Linux)
            if ! [ -r /etc/os-release ] || ! [[ "$(cat /etc/os-release)" == *Ubuntu* ]]; then
                warn "Ubuntu 以外なので apt の mosh は入れない。必要なら手で入れること。"
                return 1
            fi
            if [ "$(dpkg-query -W -f='${Status}' mosh 2>/dev/null)" = "install ok installed" ]; then
                info "apt の mosh は導入済み"
                return 0
            fi
            info "apt で mosh を入れる ..."
            sudo apt install -y mosh
            ;;
        Darwin)
            if ! command -v brew >/dev/null 2>&1; then
                warn "brew が無いので mosh を入れられない。Homebrew を入れてから再実行すること。"
                return 1
            fi
            if brew list --formula mosh >/dev/null 2>&1; then
                info "brew の mosh は導入済み"
                return 0
            fi
            info "brew で mosh を入れる ..."
            brew install mosh
            ;;
        *)
            warn "$os では mosh のデフォルトの入れ方を用意していない。"
            return 1
            ;;
    esac
}

# 失敗したら理由を 1 行 stderr に出して非 0 を返す。PREFIX は元のままにする。
install_custom() {
    local platform
    case "$os/$(uname -m)" in
        Linux/x86_64)  platform=linux-x86_64 ;;
        Darwin/arm64)  platform=macos-arm64 ;;
        *) warn "対象外の環境 ($os/$(uname -m)) なので、カスタム版のビルドが無い"; return 1 ;;
    esac

    local tag="${MOSH_VERSION:-}"
    if [ -z "$tag" ]; then
        tag="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null \
            | sed -nE 's/.*"tag_name": *"([^"]+)".*/\1/p' | head -n1)" || true
    fi
    if [ -z "$tag" ]; then
        warn "最新リリースのタグを解決できない (GitHub API に届かないか、レート制限)"
        return 1
    fi

    if [ -x "$PREFIX/bin/mosh-client" ] && built_from "$PREFIX/bin/mosh-client" "$tag"; then
        info "カスタム版の mosh ($tag) は導入済み: $PREFIX/bin"
        return 0
    fi

    # 作業場所を PREFIX の中に作るのは、最後の mv を同じファイルシステム内の rename にするため。
    # 動いている mosh-server の実行ファイルに上書きで書き込むと ETXTBSY で失敗するが、
    # rename で差し替えれば、動いているプロセスは古いファイルのまま続く。
    # /tmp が別のファイルシステムだと mv はコピーになり、この性質が保てない。
    if ! mkdir -p "$PREFIX" || ! WORKDIR="$(mktemp -d "$PREFIX/.mosh-install.XXXXXX")"; then
        warn "$PREFIX に作業ディレクトリを作れない"
        return 1
    fi
    trap 'rm -rf "$WORKDIR"' EXIT

    local asset="mosh-$tag-$platform.tar.gz"
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

    mkdir "$WORKDIR/new" "$WORKDIR/old"
    if ! tar -xzf "$WORKDIR/$asset" --strip-components=1 -C "$WORKDIR/new"; then
        warn "$asset を展開できない"
        return 1
    fi
    local f
    for f in "${FILES[@]}"; do
        if ! [ -f "$WORKDIR/new/$f" ]; then
            warn "$asset に $f が無い"
            return 1
        fi
    done
    if ! built_from "$WORKDIR/new/bin/mosh-client" "$tag"; then
        warn "$asset の mosh-client がこのマシンで起動できない (glibc が古いなど)"
        return 1
    fi

    # 既存のファイルは old/ へ退避してから置く。置いたあとに動かなければ戻す。
    mkdir -p "$PREFIX/bin" "$PREFIX/share/man/man1"
    for f in "${FILES[@]}"; do
        mkdir -p "$WORKDIR/old/$(dirname "$f")"
        if [ -e "$PREFIX/$f" ]; then
            mv -f "$PREFIX/$f" "$WORKDIR/old/$f"
        fi
        mv -f "$WORKDIR/new/$f" "$PREFIX/$f"
    done

    if ! built_from "$PREFIX/bin/mosh-client" "$tag"; then
        for f in "${FILES[@]}"; do
            rm -f "$PREFIX/$f"
            if [ -e "$WORKDIR/old/$f" ]; then
                mv -f "$WORKDIR/old/$f" "$PREFIX/$f"
            fi
        done
        warn "置いた $PREFIX/bin/mosh-client が起動できないので、元に戻した"
        return 1
    fi

    info "Installed: $("$PREFIX/bin/mosh-client" --version 2>/dev/null | head -n1)  ->  $PREFIX/bin"
    case ":$PATH:" in
        *":$PREFIX/bin:"* | *":$PREFIX/bin/:"*) ;;
        *) warn "NOTE: $PREFIX/bin が \$PATH に無い。シェル設定に追加して下さい。" ;;
    esac
}

if install_custom; then
    exit 0
fi

warn "カスタム版の mosh を入れられないので、デフォルトの mosh にする。"
install_default

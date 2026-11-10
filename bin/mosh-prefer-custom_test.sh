#!/usr/bin/env bash
# mosh-prefer-custom のテスト。
# HOME を一時ディレクトリに差し替え、mosh はスタブ（受け取った引数を 1 行ずつ出す）に
# 置き換える。本物の mosh は起動しない。
set -uo pipefail

SELF_DIR=$(cd "$(dirname "$0")" && pwd)
TARGET="$SELF_DIR/mosh-prefer-custom"
TMPDIR_T=$(mktemp -d)
FAKE_HOME="$TMPDIR_T/home"
STUB_PATH="$TMPDIR_T/path"

pass=0
fail=0

cleanup() {
    rm -rf "$TMPDIR_T"
}
trap cleanup EXIT

check() {
    local label="$1" want="$2" got="$3"
    if [ "$want" = "$got" ]; then
        printf '  ok   %-56s = [%s]\n' "$label" "$got"
        pass=$((pass + 1))
    else
        printf '  FAIL %-56s want=[%s] got=[%s]\n' "$label" "$want" "$got"
        fail=$((fail + 1))
    fi
}

make_stub() {
    local path="$1" name="$2"
    mkdir -p "$(dirname "$path")"
    printf '#!/bin/sh\necho %s\nfor a in "$@"; do printf "%%s\\n" "$a"; done\n' "$name" > "$path"
    chmod +x "$path"
}

run_target() {
    HOME="$FAKE_HOME" PATH="$STUB_PATH:/usr/bin:/bin" "$TARGET" "$@"
}

# mosh が --server の値をリモートのシェルでどう展開するかを、指定したシェルで再現する
resolve_server() {
    local shell="$1" value="$2"
    HOME="$FAKE_HOME" "$shell" -c "printf '%s\n' $value"
}

mkdir -p "$FAKE_HOME" "$STUB_PATH"
make_stub "$STUB_PATH/mosh" upstream

echo "== 手元の mosh の選択"
out=$(run_target nucbox -- sh -c 'exec ~/x')
check "~/.local/bin/mosh が無いと PATH の mosh（本家）を使う" upstream "$(sed -n 1p <<< "$out")"
check "引数はそのまま後ろに渡す（ホスト）" nucbox "$(sed -n 3p <<< "$out")"
check "引数はそのまま後ろに渡す（コマンド）" "exec ~/x" "$(sed -n 7p <<< "$out")"

make_stub "$FAKE_HOME/.local/bin/mosh" custom
out=$(run_target nucbox)
check "~/.local/bin/mosh があるとそれ（カスタム版）を使う" custom "$(sed -n 1p <<< "$out")"

chmod -x "$FAKE_HOME/.local/bin/mosh"
out=$(run_target nucbox)
check "~/.local/bin/mosh が実行できないと本家を使う" upstream "$(sed -n 1p <<< "$out")"
rm -f "$FAKE_HOME/.local/bin/mosh"

echo "== リモートの mosh-server の選択"
server_arg=$(run_target nucbox | sed -n 2p)
check "--server を mosh のオプションとして先頭に渡す" "--server=" "${server_arg:0:9}"
server_value=${server_arg#--server=}

for shell in sh bash zsh; do
    if ! command -v "$shell" > /dev/null 2>&1; then
        echo "  skip $shell が無い"
        continue
    fi
    rm -f "$FAKE_HOME/.local/bin/mosh-server"
    check "$shell: ~/.local/bin/mosh-server が無いと mosh-server（本家）" \
        mosh-server "$(resolve_server "$shell" "$server_value")"
    make_stub "$FAKE_HOME/.local/bin/mosh-server" custom
    check "$shell: ~/.local/bin/mosh-server があるとそのパス" \
        "$FAKE_HOME/.local/bin/mosh-server" "$(resolve_server "$shell" "$server_value")"
done

echo
if [ "$fail" -eq 0 ]; then
    echo "全 $pass 件 成功"
else
    echo "$pass 件成功 / $fail 件失敗"
fi
exit $((fail > 0 ? 1 : 0))

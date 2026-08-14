#!/usr/bin/env bash
# tmux-sessionizer のテスト。
# プリセットは一時ファイル（TMUX_SESSIONS_FILE）に隔離し、tmux 呼び出しは
# 使い捨てサーバ（-L sessionizer-test）に向ける。常用の tmux には触れない。
#
# 隔離は必須で、手を抜くと素の tmux が既定ソケット（＝常用サーバ）を見に行き、
# 「プリセットに無い名前でも起動中セッションの cwd を返す」フォールバックが
# 実サーバのセッションを拾ってテストが偽陽性/偽陰性になる。
set -uo pipefail

SELF_DIR=$(cd "$(dirname "$0")" && pwd)
TS="$SELF_DIR/tmux-sessionizer"
SOCK=sessionizer-test
TMPDIR_T=$(mktemp -d)
export TMUX_SESSIONS_FILE="$TMPDIR_T/sessions"

pass=0
fail=0

cleanup() {
    tmux -L "$SOCK" kill-server 2> /dev/null
    rm -f "/tmp/tmux-$(id -u)/$SOCK"
    rm -rf "$TMPDIR_T"
}
trap cleanup EXIT

check() {
    local label="$1" want="$2" got="$3"
    if [ "$want" = "$got" ]; then
        printf '  ok   %-44s = [%s]\n' "$label" "$got"
        pass=$((pass + 1))
    else
        printf '  FAIL %-44s want=[%s] got=[%s]\n' "$label" "$want" "$got"
        fail=$((fail + 1))
    fi
}

# kill-server の直後に new-session すると取りこぼすことがあるので必ず待つ
reset_server() {
    tmux -L "$SOCK" kill-server 2> /dev/null
    sleep 1
    tmux -L "$SOCK" new-session -d -s base -c /tmp
    sleep 0.5
}

# 使い捨てサーバに向けて実行する
in_test_tmux() { env TMUX="$(tmux -L "$SOCK" display -p '#{socket_path}'),0,0" "$@"; }
ts() { in_test_tmux "$TS" "$@"; }

write_conf() { printf '%s\n' "$@" > "$TMUX_SESSIONS_FILE"; }

reset_server

echo "=== 従来書式（名前だけ）が壊れていないこと ==="
write_conf '# コメント' '' 'game' 'work'
check "list は名前だけを出す" "game
work" "$(ts list)"
check "ディレクトリ未設定・未起動なら空" "" "$(ts dir game)"

echo "=== 名前 + ディレクトリ ==="
write_conf 'game	~/games/grimdawn' 'work  /tmp' 'any'
check "list はディレクトリを含めない" "game
work
any" "$(ts list)"
check "TAB 区切りを読む(~ 展開)" "$HOME/games/grimdawn" "$(ts dir game)"
check "空白区切りも読む" "/tmp" "$(ts dir work)"
check "ディレクトリ無しの行" "" "$(ts dir any)"
check "未知の名前" "" "$(ts dir nosuch)"

echo "=== プリセットに無くても起動中なら現在地を返す（フォールバック） ==="
write_conf '# empty'
check "起動中セッションの cwd" "/tmp" "$(ts dir base)"

echo "=== コメント・空行・前後の空白 ==="
write_conf '  # 先頭空白コメント' '' '   pad	/tmp   ' 'bare'
check "空白を含む行も正しく解釈" "/tmp" "$(ts dir pad)"
check "list に空行やコメントが混ざらない" "pad
bare" "$(ts list)"

echo "=== add / del ==="
write_conf 'game	~/games/grimdawn'
ts add newone /tmp
check "add NAME DIR" "/tmp" "$(ts dir newone)"
ts add bareone
check "add NAME のみ" "game
newone
bareone" "$(ts list)"
ts add newone /var
check "既存名は重複追加しない" "game
newone
bareone" "$(ts list)"
ts del newone
check "del はディレクトリ付きの行も消す" "game
bareone" "$(ts list)"
ts del game
check "del 後に残るもの" "bareone" "$(ts list)"

echo "=== add でディレクトリを自動採取（起動中セッションの現在地） ==="
write_conf '# empty'
ts add base
check "起動中セッションの cwd が記録される" "/tmp" "$(ts dir base)"

echo "=== menu の出力形（記号 TAB 名前 TAB ディレクトリ） ==="
# menu は「今いるセッション」を一覧から除くため、2 つ起動して
# 現在地でない方が ● で出ることを確かめる。
write_conf 'alpha	/tmp' 'zz	/var' 'beta'
tmux -L "$SOCK" kill-server 2> /dev/null; sleep 1
tmux -L "$SOCK" new-session -d -s alpha -c /tmp
tmux -L "$SOCK" new-session -d -s zz -c /var
sleep 0.5
cur=$(in_test_tmux tmux display-message -p '#S' 2> /dev/null)
if [ "$cur" = "alpha" ]; then other=zz; odir=/var; else other=alpha; odir=/tmp; fi
check "現在地は一覧から除かれる" "" "$(ts menu | awk -F'\t' -v c="$cur" '$2 == c')"
check "起動中は ● + 名前 + ディレクトリ" "●	$other	$odir" "$(ts menu | rg '^●' | head -1)"
check "未起動は ○ でディレクトリ空" "○	beta	" "$(ts menu | rg '^○' | head -1)"
check "列数は 3" "3" "$(ts menu | head -1 | awk -F'\t' '{print NF}')"

echo "=== 実際にセッションを作る ==="
reset_server
mkdir -p "$TMPDIR_T/themedir"
write_conf "themed	$TMPDIR_T/themedir" 'nodir'
ts switch themed > /dev/null 2>&1
sleep 0.5
check "プリセットの cwd で作られる" "$TMPDIR_T/themedir" \
    "$(tmux -L "$SOCK" list-panes -s -t '=themed' -F '#{pane_current_path}' 2> /dev/null | head -1)"
ts switch nodir > /dev/null 2>&1
sleep 0.5
check "ディレクトリ無しでも作成できる" "nodir" \
    "$(tmux -L "$SOCK" has-session -t '=nodir' 2> /dev/null && echo nodir)"

echo "=== 存在しないディレクトリでも作成は失敗しない ==="
write_conf "ghost	$TMPDIR_T/does-not-exist"
ts switch ghost > /dev/null 2>&1
sleep 0.5
check "セッションは作られる" "ghost" \
    "$(tmux -L "$SOCK" has-session -t '=ghost' 2> /dev/null && echo ghost)"

echo
if [ "$fail" -eq 0 ]; then
    echo "全 $pass 件 成功"
else
    echo "$pass 件成功 / $fail 件失敗"
fi
exit $((fail > 0 ? 1 : 0))

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

echo "=== 既存行のディレクトリが空なら後から埋まる ==="
write_conf 'game' 'work	/var'
ts add game /tmp
check "空の行は埋まる" "/tmp" "$(ts dir game)"
check "他の行は壊れない" "/var" "$(ts dir work)"
ts add game /usr
check "既に入っている値は上書きしない" "/tmp" "$(ts dir game)"
check "行数は増えない" "game
work" "$(ts list)"

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

echo "=== セッション終了時のフォールバック ==="
# 実クライアントが要るので、外側の tmux も使い捨てソケットに立てる。
# 既定ソケット（常用サーバ）に外側セッションを作ってはいけない。
OUT="${SOCK}-outer"
fb_setup() {
    tmux -L "$SOCK" kill-server 2> /dev/null
    tmux -L "$OUT" kill-server 2> /dev/null
    sleep 1
    rm -rf "${XDG_RUNTIME_DIR:-/tmp}/tmux-sessionizer-$(id -u)"
    tmux -L "$SOCK" new-session -d -s any  -c /tmp
    tmux -L "$SOCK" new-session -d -s work -c /usr
    tmux -L "$SOCK" new-session -d -s game -c /var
    tmux -L "$SOCK" set -g detach-on-destroy off
    tmux -L "$SOCK" set-hook -g client-session-changed \
        "run-shell -b \"TMUX_SESSIONS_FILE=$TMUX_SESSIONS_FILE $TS on-session-changed #{hook_client} #{client_session}\""
    tmux -L "$OUT" new-session -d -s host "TERM=xterm-256color tmux -L $SOCK attach -t work"
    sleep 2
    CL=$(tmux -L "$SOCK" list-clients -F '#{client_tty}' | head -1)
}
fb_where() { tmux -L "$SOCK" list-clients -F '#{client_session}' 2> /dev/null | head -1; }

write_conf 'any	/tmp' 'work	/usr' 'game	/var'

fb_setup
tmux -L "$SOCK" switch-client -c "$CL" -t game; sleep 2
check "手動の切り替えでは動かない" "game" "$(fb_where)"
tmux -L "$SOCK" kill-session -t game; sleep 3
check "居るセッションが終了したら移る" "any" "$(fb_where)"

fb_setup
tmux -L "$SOCK" switch-client -c "$CL" -t game; sleep 2
tmux -L "$SOCK" kill-session -t work; sleep 3
check "無関係なセッションの終了では動かない" "game" "$(fb_where)"

# tmux 既定の行き先（この構成では any）と違う所を指定して、フックが効いている
# ことを決定的に確かめる。これが無いと「たまたま any だった」と区別が付かない。
fb_setup
tmux -L "$SOCK" new-session -d -s zzz -c /etc
tmux -L "$SOCK" set -g @fallback_session zzz
tmux -L "$SOCK" switch-client -c "$CL" -t game; sleep 2
tmux -L "$SOCK" kill-session -t game; sleep 3
check "@fallback_session の指定を尊重する" "zzz" "$(fb_where)"

fb_setup
tmux -L "$SOCK" kill-session -t any; sleep 1
tmux -L "$SOCK" switch-client -c "$CL" -t game; sleep 2
tmux -L "$SOCK" kill-session -t game; sleep 3
check "フォールバック先が無ければ作る" "any" "$(fb_where)"
check "作成時はプリセットの cwd を使う" "/tmp" \
    "$(tmux -L "$SOCK" list-panes -s -t '=any' -F '#{pane_current_path}' 2> /dev/null | head -1)"

fb_setup
tmux -L "$SOCK" switch-client -c "$CL" -t any; sleep 2
tmux -L "$SOCK" kill-session -t any; sleep 3
check "フォールバック先自身の終了で暴れない" "yes" \
    "$([ -n "$(fb_where)" ] && echo yes || echo no)"

tmux -L "$OUT" kill-server 2> /dev/null
rm -f "/tmp/tmux-$(id -u)/$OUT"
rm -rf "${XDG_RUNTIME_DIR:-/tmp}/tmux-sessionizer-$(id -u)"

echo
if [ "$fail" -eq 0 ]; then
    echo "全 $pass 件 成功"
else
    echo "$pass 件成功 / $fail 件失敗"
fi
exit $((fail > 0 ? 1 : 0))

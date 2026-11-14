#!/usr/bin/env bash
# tmux-swipe-window のテスト。
# tmux は使い捨てサーバ（-L swipe-test）、時刻の記録は一時ディレクトリに隔離する。
# tmux.conf と同じく run-shell 経由で呼び、サーバから渡る TMUX で対象を引かせる。
set -uo pipefail

SELF_DIR=$(cd "$(dirname "$0")" && pwd)
SW="$SELF_DIR/tmux-swipe-window"
SOCK=swipe-test
TMPDIR_T=$(mktemp -d)
export TMUX_SWIPE_STAMP="$TMPDIR_T/stamp"
export TMUX_SWIPE_GAP_MS=300

pass=0
fail=0

cleanup() {
    tmux -L "$SOCK" kill-server 2> /dev/null
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

t() { tmux -L "$SOCK" "$@"; }
swipe() { t run-shell "$SW $1 '\$0'"; }
current() { t display -p -t '$0' '#{window_index}'; }

t -f /dev/null new -d -s s0 \; new-window \; new-window \; select-window -t :0
# 環境変数は run-shell の子に渡るよう、サーバの global environment に入れる。
t setenv -g TMUX_SWIPE_STAMP "$TMUX_SWIPE_STAMP"
t setenv -g TMUX_SWIPE_GAP_MS "$TMUX_SWIPE_GAP_MS"

swipe next
check "間隔の空いた最初のイベントで次のウィンドウへ移る" 1 "$(current)"

for _ in 1 2 3 4 5 6 7 8; do swipe next; done
check "間隔を空けずに続くイベントでは移らない" 1 "$(current)"

sleep 0.4
swipe previous
check "間隔が空いた後のイベントで前のウィンドウへ移る" 0 "$(current)"

for _ in 1 2 3 4 5; do sleep 0.1; swipe next; done
check "慣性のように間隔未満で長く続くイベントでは移らない" 0 "$(current)"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]

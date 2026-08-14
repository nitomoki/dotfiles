#!/usr/bin/env bash
# cc-status.sh のテスト。使い捨ての tmux サーバ (-L cc-status-test) を立てて、
# フックから呼ばれたときと同じ環境変数を与えて挙動を確認する。
# 常用の tmux サーバには一切触れない。
set -uo pipefail

HOOK="$(cd "$(dirname "$0")" && pwd)/cc-status.sh"
SOCK=cc-status-test
T="tmux -L $SOCK"

pass=0
fail=0

cleanup() { $T kill-server 2> /dev/null; rm -f "/tmp/tmux-$(id -u)/$SOCK"; }
trap cleanup EXIT

check() {
    local label="$1" want="$2" got="$3"
    if [ "$want" = "$got" ]; then
        printf '  ok   %-46s = [%s]\n' "$label" "$got"
        pass=$((pass + 1))
    else
        printf '  FAIL %-46s want=[%s] got=[%s]\n' "$label" "$want" "$got"
        fail=$((fail + 1))
    fi
}

# フックと同じ環境で起動する。claude の代わりに sleep を走らせ、
# pane_current_command がシェル以外になる状況を作る。
run_hook() {
    local pane="$1"
    shift
    env TMUX="$($T display -p '#{socket_path}'),0,0" TMUX_PANE="$pane" "$HOOK" "$@"
}

sess_status() { $T show -t "$1" -v @cc_status 2> /dev/null; }

cleanup
$T new-session -d -s alpha -c /tmp 'sleep 600'
$T new-session -d -s beta  -c /tmp 'sleep 600'
$T new-window  -d -t alpha -c /tmp 'sleep 600'
sleep 1

A1=$($T list-panes -t alpha:0 -F '#{pane_id}' | head -1)
A2=$($T list-panes -t alpha:1 -F '#{pane_id}' | head -1)
B1=$($T list-panes -t beta:0  -F '#{pane_id}' | head -1)

echo "=== 単一ペインの状態遷移 ==="
run_hook "$A1" busy;    check "busy を書いたら alpha" "busy" "$(sess_status alpha)"
run_hook "$A1" waiting; check "waiting へ遷移" "waiting" "$(sess_status alpha)"
run_hook "$A1" done;    check "done へ遷移" "done" "$(sess_status alpha)"
run_hook "$A1" clear;   check "clear で消える" "" "$(sess_status alpha)"

echo "=== 同一セッションに複数 Claude（優先順位） ==="
run_hook "$A1" busy
run_hook "$A2" waiting
check "busy と waiting → waiting が勝つ" "waiting" "$(sess_status alpha)"
run_hook "$A2" done
check "busy と done → done が勝つ" "done" "$(sess_status alpha)"
run_hook "$A2" clear
check "片方消すと残りが出る" "busy" "$(sess_status alpha)"

echo "=== セッションが混ざらないこと ==="
run_hook "$B1" waiting
check "beta は waiting" "waiting" "$(sess_status beta)"
check "alpha は busy のまま" "busy" "$(sess_status alpha)"

echo "=== visit で done だけ落ちる ==="
run_hook "$A1" done
run_hook "$A2" waiting
run_hook "$A1" visit alpha
check "visit 後: waiting は残る" "waiting" "$(sess_status alpha)"
run_hook "$A2" clear
run_hook "$A1" done
run_hook "$A1" visit alpha
check "visit 後: done は消える" "" "$(sess_status alpha)"
check "visit は他セッションに波及しない" "waiting" "$(sess_status beta)"

echo "=== claude が死んだ後の残骸を拾わない ==="
run_hook "$A1" busy
check "sleep が動いている間は busy" "busy" "$(sess_status alpha)"
$T send-keys -t "$A1" C-c 2> /dev/null
$T respawn-pane -k -t "$A1" 'sh -c "exec sh"' 2> /dev/null
sleep 1
run_hook "$B1" busy   # 集約を走らせるためだけの発火
check "シェルに戻ったペインの状態は無視される" "" "$(sess_status alpha)"

echo "=== tmux の外から呼ばれても壊れない ==="
out=$(env -u TMUX -u TMUX_PANE "$HOOK" busy 2>&1); rc=$?
check "TMUX 無しでも正常終了" "0" "$rc"
check "TMUX 無しでは何も出力しない" "" "$out"

echo
if [ "$fail" -eq 0 ]; then
    echo "全 $pass 件 成功"
else
    echo "$pass 件成功 / $fail 件失敗"
fi
exit $((fail > 0 ? 1 : 0))

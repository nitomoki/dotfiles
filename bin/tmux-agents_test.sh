#!/usr/bin/env bash
# tmux-agents のテスト。
# tmux は使い捨てサーバ（-L agents-test）、claude はスタブ、セッション記録は
# 一時ディレクトリ（CLAUDE_SESSIONS_DIR）に隔離する。常用の tmux にも
# ~/.claude/sessions にも触れない。
set -uo pipefail

SELF_DIR=$(cd "$(dirname "$0")" && pwd)
TA="$SELF_DIR/tmux-agents"
SOCK=agents-test
TMPDIR_T=$(mktemp -d)
STUB="$TMPDIR_T/stub"
export CLAUDE_SESSIONS_DIR="$TMPDIR_T/sessions"
export TMUX_SESSIONS_FILE="$TMPDIR_T/presets"
export TMUX_AGENTS_HANDOFF_TIMEOUT=6

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
        printf '  ok   %-46s = [%s]\n' "$label" "$got"
        pass=$((pass + 1))
    else
        printf '  FAIL %-46s want=[%s] got=[%s]\n' "$label" "$want" "$got"
        fail=$((fail + 1))
    fi
}

mkdir -p "$STUB" "$CLAUDE_SESSIONS_DIR" "$TMPDIR_T/themedir"
# claude のスタブ。起動しっぱなしにして pane_current_command を claude にする。
cat > "$STUB/claude" <<'EOF'
#!/bin/sh
exec sleep 600
EOF
chmod +x "$STUB/claude"
# handoff のテストでは pane_current_command が claude である必要がある。
# シェルスクリプトだと comm がインタプリタ名になってしまうので、実バイナリを
# claude という名前でコピーして使う（引数を取れるよう sleep を流用）。
STUB2="$TMPDIR_T/stub2"
mkdir -p "$STUB2"
cp -- "$(command -v sleep)" "$STUB2/claude"
printf 'themed\t%s\n' "$TMPDIR_T/themedir" > "$TMUX_SESSIONS_FILE"
printf 'nodir\n' >> "$TMUX_SESSIONS_FILE"

# 使い捨てサーバはスタブを PATH に入れて起動する（窓の中の claude もスタブになる）
start_server() {
    tmux -L "$SOCK" kill-server 2> /dev/null
    sleep 1
    PATH="$STUB:$PATH" tmux -L "$SOCK" new-session -d -s themed -c "$TMPDIR_T/themedir"
    PATH="$STUB:$PATH" tmux -L "$SOCK" new-session -d -s nodir -c /tmp
    sleep 0.5
}

# スクリプトを使い捨てサーバに向けて実行する
ta() {
    env TMUX="$(tmux -L "$SOCK" display -p '#{socket_path}'),0,0" PATH="$STUB:$PATH" "$TA" "$@"
}

start_server

echo "=== open: テーマのディレクトリを --cwd に渡す ==="
ta open themed > /dev/null 2>&1
sleep 1
check "agents ウィンドウができる" "agents" \
    "$(tmux -L "$SOCK" list-windows -t '=themed' -F '#{window_name}' | rg '^agents$')"
check "--cwd にテーマのディレクトリ" "claude agents --cwd '$TMPDIR_T/themedir'" \
    "$(tmux -L "$SOCK" list-panes -t '=themed:agents' -F '#{pane_start_command}' | head -1 | sed 's/^"//;s/"$//')"
check "ウィンドウの cwd もテーマの場所" "$TMPDIR_T/themedir" \
    "$(tmux -L "$SOCK" list-panes -t '=themed:agents' -F '#{pane_current_path}' | head -1)"

echo "=== open: 2 回目は既存ウィンドウを選ぶ（増やさない） ==="
ta open themed > /dev/null 2>&1
sleep 0.5
check "agents ウィンドウは 1 枚のまま" "1" \
    "$(tmux -L "$SOCK" list-windows -t '=themed' -F '#{window_name}' | rg -c '^agents$')"

echo "=== open: プリセットに無くても起動中セッションの cwd で絞る ==="
ta open nodir > /dev/null 2>&1
sleep 1
check "セッションの現在地を --cwd に使う" "claude agents --cwd '/tmp'" \
    "$(tmux -L "$SOCK" list-panes -t '=nodir:agents' -F '#{pane_start_command}' | head -1 | sed 's/^"//;s/"$//')"

echo "=== open: ディレクトリが分からなければ全体を出す ==="
start_server
# tmux-sessionizer に届かない状況（PATH からも $HOME からも見えない）を作る。
# 起動中セッションの cwd フォールバックも sessionizer 側の機能なので、
# ここまでしないと「ディレクトリ不明」の枝には入らない。
env TMUX="$(tmux -L "$SOCK" display -p '#{socket_path}'),0,0" \
    PATH="$STUB:/usr/bin:/bin" HOME=/nonexistent "$TA" open themed > /dev/null 2>&1
sleep 1
check "--cwd を付けない" "claude agents" \
    "$(tmux -L "$SOCK" list-panes -t '=themed:agents' -F '#{pane_start_command}' | head -1 | sed 's/^"//;s/"$//')"

echo "=== open: @agents_window を尊重する ==="
tmux -L "$SOCK" set -g @agents_window fleet
ta open themed > /dev/null 2>&1
sleep 1
check "指定した名前で作る" "fleet" \
    "$(tmux -L "$SOCK" list-windows -t '=themed' -F '#{window_name}' | rg '^fleet$')"
tmux -L "$SOCK" set -gu @agents_window

echo "=== 外側からの誤爆を防ぐ ==="
out=$(env -u TMUX "$TA" open 2>&1); rc=$?
check "tmux 外では何もしない (rc)" "1" "$rc"
check "tmux 外ではメッセージを標準エラーへ" "yes" \
    "$(printf '%s' "$out" | rg -q 'tmux の中で' && echo yes || echo no)"

echo "=== handoff: claude が動いていないペインは触らない ==="
start_server
before_pid=$(tmux -L "$SOCK" list-panes -t '=themed:0' -F '#{pane_pid}' | head -1)
pane=$(tmux -L "$SOCK" list-panes -t '=themed:0' -F '#{pane_id}' | head -1)
ta handoff "$pane" > /dev/null 2>&1
rc=$?
check "エラーで終わる" "1" "$rc"
check "ペインは再生成されない" "$before_pid" \
    "$(tmux -L "$SOCK" list-panes -t '=themed:0' -F '#{pane_pid}' | head -1)"

echo "=== handoff: 引き渡せたらペインを閉じる（他にペインがある場合） ==="
start_server
tmux -L "$SOCK" new-window -t '=themed' -n cc -c "$TMPDIR_T/themedir" "$STUB2/claude 600"
sleep 1.5
pane=$(tmux -L "$SOCK" list-panes -t '=themed:cc' -F '#{pane_id}' | head -1)
ppid=$(tmux -L "$SOCK" list-panes -t '=themed:cc' -F '#{pane_pid}' | head -1)
check "スタブが claude として見える" "claude" \
    "$(tmux -L "$SOCK" list-panes -t '=themed:cc' -F '#{pane_current_command}' | head -1)"
printf '{"pid":%s,"parkedJobId":null}\n' "$ppid" > "$CLAUDE_SESSIONS_DIR/$ppid.json"
# Claude Code が引き渡しを終えた状況を、少し遅れて作る
( sleep 2; printf '{"pid":%s,"parkedJobId":"deadbeef"}\n' "$ppid" > "$CLAUDE_SESSIONS_DIR/$ppid.json" ) &
ta handoff "$pane" > /dev/null 2>&1
rc=$?
sleep 1
check "成功で終わる" "0" "$rc"
check "ペインが閉じる" "gone" \
    "$(tmux -L "$SOCK" list-panes -s -t '=themed' -F '#{pane_id}' | rg -q "^$pane$" && echo alive || echo gone)"
check "セッションは残る" "themed" \
    "$(tmux -L "$SOCK" has-session -t '=themed' 2> /dev/null && echo themed)"
wait 2> /dev/null

echo "=== handoff: セッション最後の 1 つなら作り直して器を残す ==="
start_server
tmux -L "$SOCK" new-session -d -s solo -c "$TMPDIR_T/themedir" "$STUB2/claude 600"
sleep 1.5
check "solo は 1 ペインだけ" "1" \
    "$(tmux -L "$SOCK" list-panes -s -t '=solo' -F '#{pane_id}' | wc -l)"
pane=$(tmux -L "$SOCK" list-panes -t '=solo' -F '#{pane_id}' | head -1)
ppid=$(tmux -L "$SOCK" list-panes -t '=solo' -F '#{pane_pid}' | head -1)
printf '{"pid":%s,"parkedJobId":null}\n' "$ppid" > "$CLAUDE_SESSIONS_DIR/$ppid.json"
( sleep 2; printf '{"pid":%s,"parkedJobId":"cafe"}\n' "$ppid" > "$CLAUDE_SESSIONS_DIR/$ppid.json" ) &
ta handoff "$pane" > /dev/null 2>&1
rc=$?
sleep 1
check "成功で終わる" "0" "$rc"
check "セッションが消えない" "solo" \
    "$(tmux -L "$SOCK" has-session -t '=solo' 2> /dev/null && echo solo)"
check "ペインは作り直される（pid が変わる）" "changed" \
    "$([ "$(tmux -L "$SOCK" list-panes -s -t '=solo' -F '#{pane_pid}' | head -1)" != "$ppid" ] && echo changed || echo same)"
wait 2> /dev/null

echo "=== handoff: 確認できなければペインを残す ==="
start_server
tmux -L "$SOCK" new-window -t '=themed' -n cc2 -c "$TMPDIR_T/themedir" "$STUB2/claude 600"
sleep 1.5
pane=$(tmux -L "$SOCK" list-panes -t '=themed:cc2' -F '#{pane_id}' | head -1)
ppid=$(tmux -L "$SOCK" list-panes -t '=themed:cc2' -F '#{pane_pid}' | head -1)
printf '{"pid":%s,"parkedJobId":null}\n' "$ppid" > "$CLAUDE_SESSIONS_DIR/$ppid.json"
ta handoff "$pane" > /dev/null 2>&1
rc=$?
check "エラーで終わる" "1" "$rc"
check "ペインはそのまま残る" "$ppid" \
    "$(tmux -L "$SOCK" list-panes -t '=themed:cc2' -F '#{pane_pid}' | head -1)"

echo
if [ "$fail" -eq 0 ]; then
    echo "全 $pass 件 成功"
else
    echo "$pass 件成功 / $fail 件失敗"
fi
exit $((fail > 0 ? 1 : 0))

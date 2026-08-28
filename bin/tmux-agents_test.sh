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
export CC_PEER_TIMEOUT=4
LIVE_PID_FILE="$TMPDIR_T/live-pids"

pass=0
fail=0

cleanup() {
    tmux -L "$SOCK" kill-server 2> /dev/null
    rm -f "/tmp/tmux-$(id -u)/$SOCK"
    # peer のテストが借りた sleep を片付ける（残すと 10 分居座る）
    [ -f "$LIVE_PID_FILE" ] && xargs -r kill < "$LIVE_PID_FILE" 2> /dev/null
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
# peer spawn は git 管理下のときだけ -w（worktree）を付ける。両方の枝を試すため、
# themed のディレクトリだけリポジトリにしておく（themed2 は git 管理外のまま）。
git init -q "$TMPDIR_T/themedir" 2> /dev/null
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
# peer spawn がテーマの tmux セッションごと作る枝を試すため、起動していない
# テーマもプリセットに置いておく。
mkdir -p "$TMPDIR_T/themedir2"
printf 'themed2\t%s\n' "$TMPDIR_T/themedir2" >> "$TMUX_SESSIONS_FILE"

# ── peer 用のヘルパ ──────────────────────────────────────────────
# レジストリの偽エントリ。tmux-agents は pid の生存を見るので、生きた sleep の
# pid を借りて割り当てる。バックグラウンド起動の出力はコマンド置換のパイプを
# 掴んだままにしないよう捨てる。
live_pid() {
    sleep 600 > /dev/null 2>&1 &
    local p=$!
    printf '%s\n' "$p" >> "$LIVE_PID_FILE"
    printf '%s' "$p"
}

# 既に死んでいる pid（消し損ねた残骸を作るため）
dead_pid() {
    sleep 0.1 > /dev/null 2>&1 &
    local p=$!
    wait "$p" 2> /dev/null
    printf '%s' "$p"
}

# reg_json PID NAME CWD TMUX KIND STATUS UPDATED_AT
reg_json() {
    printf '{"pid":%s,"sessionId":"t","cwd":"%s","tmux":"%s","kind":"%s","name":"%s","nameSource":"user","status":"%s","updatedAt":%s}\n' \
        "$1" "$3" "$4" "$5" "$2" "$6" "$7" > "$CLAUDE_SESSIONS_DIR/$1.json"
}

clear_reg() {
    rm -f "$CLAUDE_SESSIONS_DIR"/*.json
}

# 使い捨てサーバはスタブを PATH に入れて起動する（窓の中の claude もスタブになる）
start_server() {
    tmux -L "$SOCK" kill-server 2> /dev/null
    sleep 1
    PATH="$STUB:$PATH" tmux -L "$SOCK" new-session -d -s themed -c "$TMPDIR_T/themedir"
    PATH="$STUB:$PATH" tmux -L "$SOCK" new-session -d -s nodir -c /tmp
    sleep 0.5
}

# スクリプトを使い捨てサーバに向けて実行する。
# $TMUX_PANE は「呼び出し元自身を候補から外す」判定に使われるため、外から
# 継承した値が混ざらないよう常に明示する（TA_PANE で差し替えられる）。
ta() {
    env TMUX="$(tmux -L "$SOCK" display -p '#{socket_path}'),0,0" \
        TMUX_PANE="${TA_PANE:-%999}" PATH="$STUB:$PATH" "$TA" "$@"
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

echo "=== セッションと同名のウィンドウが在っても新しい窓を作れる ==="
# new-window の -t は「ウィンドウ指定」なので、コロンを付け忘れると同名の
# ウィンドウに当たって "index 0 in use" で落ちる（実際に踏んだ）。
start_server
clear_reg
tmux -L "$SOCK" rename-window -t '=themed:0' themed
ta open themed > /dev/null 2>&1
sleep 1
check "open: agents ウィンドウができる" "agents" \
    "$(tmux -L "$SOCK" list-windows -t '=themed' -F '#{window_name}' | rg '^agents$')"
p=$(live_pid)
( sleep 1.5; reg_json "$p" same-name "$TMPDIR_T/themedir" "themed:@9.%9" interactive idle 100 ) &
out=$(ta peer spawn themed same-name); rc=$?
check "peer spawn: 成功で終わる" "0" "$rc"
check "peer spawn: 名前を返す" "same-name" "$out"

# ── peer ─────────────────────────────────────────────────────────
# レジストリは pid の生存で選り分けるので、偽エントリにも実プロセスを割り当てる
# （生きた sleep の pid を借りる）。tmux 側の状態は使い捨てサーバのものを使う。

start_server
themed_pane=$(tmux -L "$SOCK" list-panes -t '=themed:0' -F '#{pane_id}' | head -1)

echo "=== peer resolve: テーマの担当セッション名を返す ==="
clear_reg
p=$(live_pid); reg_json "$p" peer-old "$TMPDIR_T/themedir" "themed:@0.$themed_pane" interactive idle 100
check "候補が 1 つならそれを返す" "peer-old" "$(ta peer resolve themed)"

p=$(live_pid); reg_json "$p" peer-new "$TMPDIR_T/themedir" "themed:@1.%9" interactive idle 200
check "複数なら updatedAt が最新" "peer-new" "$(ta peer resolve themed)"

p=$(live_pid); reg_json "$p" peer-job "$TMPDIR_T/themedir" "themed:@2.%9" background idle 300
check "interactive 以外は選ばない" "peer-new" "$(ta peer resolve themed)"

p=$(live_pid); reg_json "$p" peer-cwd "$TMPDIR_T/themedir/sub" "other:@3.%9" interactive idle 400
check "別テーマでも cwd 配下なら拾う" "peer-cwd" "$(ta peer resolve themed)"

dead=$(dead_pid); reg_json "$dead" peer-stale "$TMPDIR_T/themedir" "themed:@4.%9" interactive idle 500
check "死んだ pid の残骸は無視する" "peer-cwd" "$(ta peer resolve themed)"

echo "=== peer resolve: 呼び出し元自身は候補にしない ==="
clear_reg
p=$(live_pid); reg_json "$p" self-session "$TMPDIR_T/themedir" "themed:@0.%77" interactive idle 200
p=$(live_pid); reg_json "$p" other-session "$TMPDIR_T/themedir" "themed:@1.%78" interactive idle 100
check "無関係なペインからなら最新を返す" "self-session" "$(ta peer resolve themed)"
TA_PANE=%77
check "自分のペインのセッションは外す" "other-session" "$(ta peer resolve themed)"
unset TA_PANE

echo "=== peer resolve: 担当が居なければ黙って失敗しない ==="
out=$(ta peer resolve ghost 2>&1); rc=$?
check "担当が居なければ exit 1" "1" "$rc"
check "理由は標準エラーへ" "yes" \
    "$(printf '%s' "$out" | rg -q '担当する対話セッション' && echo yes || echo no)"

echo "=== peer list: 受け入れ可否を添えて一覧する ==="
clear_reg
p=$(live_pid); reg_json "$p" list-idle "$TMPDIR_T/themedir" "themed:@0.%9" interactive idle 100
p=$(live_pid); reg_json "$p" list-busy "$TMPDIR_T/themedir" "themed:@1.%9" interactive busy 200
p=$(live_pid); reg_json "$p" list-job "$TMPDIR_T/themedir" "themed:@2.%9" background idle 300
p=$(live_pid); reg_json "$p" list-wait "$TMPDIR_T/themedir" "themed:@3.$themed_pane" interactive idle 400
tmux -L "$SOCK" set -p -t "$themed_pane" @cc_state waiting
listing=$(ta peer list)
check "idle は yes" "yes" "$(printf '%s\n' "$listing" | awk '$2 == "list-idle" { print $6 }')"
check "registry busy は busy" "busy" "$(printf '%s\n' "$listing" | awk '$2 == "list-busy" { print $6 }')"
check "バックグラウンドジョブは job" "job" "$(printf '%s\n' "$listing" | awk '$2 == "list-job" { print $6 }')"
check "@cc_state waiting は waiting" "waiting" "$(printf '%s\n' "$listing" | awk '$2 == "list-wait" { print $6 }')"
tmux -L "$SOCK" set -p -t "$themed_pane" -u @cc_state

echo "=== peer spawn: -n で明示名を付けて起動し、登録を待つ ==="
clear_reg
p=$(live_pid)
( sleep 1.5; reg_json "$p" spawn-ok "$TMPDIR_T/themedir" "themed:@8.%9" interactive idle 800 ) &
out=$(ta peer spawn themed spawn-ok); rc=$?
check "成功で終わる" "0" "$rc"
check "名前を標準出力へ" "spawn-ok" "$out"
check "claude -n と -w で起動する" "yes" \
    "$(tmux -L "$SOCK" list-panes -s -t '=themed' -F '#{pane_start_command}' \
        | rg -q "claude -n 'spawn-ok' -w 'spawn-ok'" && echo yes || echo no)"

echo "=== peer spawn: 同名が生きていたら増やさない ==="
before=$(tmux -L "$SOCK" list-windows -t '=themed' -F '#{window_id}' | wc -l)
out=$(ta peer spawn themed spawn-ok 2>&1); rc=$?
check "exit 1" "1" "$rc"
check "既に居ると伝える" "yes" \
    "$(printf '%s' "$out" | rg -q '既に起動しています' && echo yes || echo no)"
check "ウィンドウは増えない" "$before" \
    "$(tmux -L "$SOCK" list-windows -t '=themed' -F '#{window_id}' | wc -l)"

echo "=== peer spawn: ディレクトリが分からないテーマは起動しない ==="
out=$(ta peer spawn ghost 2>&1); rc=$?
check "exit 1" "1" "$rc"
check "ディレクトリ不明と伝える" "yes" \
    "$(printf '%s' "$out" | rg -q 'ディレクトリが分かりません' && echo yes || echo no)"

echo "=== peer spawn: 名前に使えない文字は弾く ==="
out=$(ta peer spawn themed 'bad name;rm' 2>&1); rc=$?
check "exit 1" "1" "$rc"
check "文字種を伝える" "yes" \
    "$(printf '%s' "$out" | rg -q '名前に使えるのは' && echo yes || echo no)"

echo "=== peer spawn: 時間内に現れなければ exit 1（ウィンドウは残す） ==="
clear_reg
out=$(ta peer spawn themed2 never-shows 2>&1); rc=$?
check "exit 1" "1" "$rc"
check "テーマのセッションが無ければ作る" "themed2" \
    "$(tmux -L "$SOCK" has-session -t '=themed2' 2> /dev/null && echo themed2)"
check "ウィンドウは残す" "yes" \
    "$(tmux -L "$SOCK" list-panes -s -t '=themed2' -F '#{pane_start_command}' \
        | rg -q "claude -n 'never-shows'" && echo yes || echo no)"
check "信頼ダイアログの可能性を伝える" "yes" \
    "$(printf '%s' "$out" | rg -q '信頼ダイアログ' && echo yes || echo no)"
check "git 管理外なら worktree なしと伝える" "yes" \
    "$(printf '%s' "$out" | rg -q 'git 管理下ではない' && echo yes || echo no)"
check "git 管理外なら -w を付けない" "no" \
    "$(tmux -L "$SOCK" list-panes -s -t '=themed2' -F '#{pane_start_command}' \
        | rg -q -- "-w " && echo yes || echo no)"

echo "=== peer ensure: 既定は spawn（受け入れ可の既存が居ても相乗りしない） ==="
clear_reg
p=$(live_pid); reg_json "$p" ensure-idle "$TMPDIR_T/themedir" "themed:@0.%9" interactive idle 100
p=$(live_pid)
( sleep 1.5; reg_json "$p" themed-cc "$TMPDIR_T/themedir" "themed:@9.%9" interactive idle 900 ) &
out=$(ta peer ensure themed); rc=$?
check "成功で終わる" "0" "$rc"
check "既存ではなく新規の <theme>-cc" "themed-cc" "$out"

echo "=== peer ensure --reuse: 受け入れ可なら既存を返す ==="
clear_reg
p=$(live_pid); reg_json "$p" reuse-ok "$TMPDIR_T/themedir" "themed:@0.$themed_pane" interactive idle 100
before=$(tmux -L "$SOCK" list-windows -t '=themed' -F '#{window_id}' | wc -l)
check "既存の名前を返す" "reuse-ok" "$(ta peer ensure themed --reuse)"
check "起動しない" "$before" \
    "$(tmux -L "$SOCK" list-windows -t '=themed' -F '#{window_id}' | wc -l)"

echo "=== peer ensure --reuse: registry が busy なら spawn にフォールバック ==="
clear_reg
p=$(live_pid); reg_json "$p" reuse-busy "$TMPDIR_T/themedir" "themed:@0.$themed_pane" interactive busy 100
p=$(live_pid)
( sleep 1.5; reg_json "$p" fallback-busy "$TMPDIR_T/themedir" "themed:@10.%9" interactive idle 1000 ) &
out=$(ta peer ensure themed fallback-busy --reuse 2> /dev/null); rc=$?
check "成功で終わる" "0" "$rc"
check "新規起動した名前を返す" "fallback-busy" "$out"

echo "=== peer ensure --reuse: @cc_state が waiting なら spawn にフォールバック ==="
clear_reg
tmux -L "$SOCK" set -p -t "$themed_pane" @cc_state waiting
p=$(live_pid); reg_json "$p" reuse-wait "$TMPDIR_T/themedir" "themed:@0.$themed_pane" interactive idle 100
p=$(live_pid)
( sleep 1.5; reg_json "$p" fallback-wait "$TMPDIR_T/themedir" "themed:@11.%9" interactive idle 1100 ) &
out=$(ta peer ensure themed fallback-wait --reuse 2> /dev/null); rc=$?
check "成功で終わる" "0" "$rc"
check "新規起動した名前を返す" "fallback-wait" "$out"
tmux -L "$SOCK" set -p -t "$themed_pane" -u @cc_state

echo
if [ "$fail" -eq 0 ]; then
    echo "全 $pass 件 成功"
else
    echo "$pass 件成功 / $fail 件失敗"
fi
exit $((fail > 0 ? 1 : 0))

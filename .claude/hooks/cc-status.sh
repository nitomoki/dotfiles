#!/bin/sh
# Claude Code のフックから呼ばれ、tmux 上の Claude の状態を可視化する。
#
#   cc-status.sh busy|waiting|done|clear   フックが起きたペインの状態を更新
#   cc-status.sh visit <session>           そのセッションの done を消す（見たので）
#
# 状態の保管先は tmux 自身で、外部の状態ファイルを持たない。
#   - ペイン単位 : @cc_state  （フックが $TMUX_PANE を使って自分のペインに書く）
#   - セッション単位: @cc_status（全ペインを走査して最優先を集約したもの）
# ペインが消えればペインオプションも消えるので、stale な状態が原理的に残らない。
# （~/.claude/sessions/*.json を読む方式だと、プロセス生存確認・procStart による
#   PID 再利用の判別・pane id からのセッション解決・死んだセッションの掃除が
#   すべて必要になる。この方式ならどれも要らない。）
#
# 優先順位は「対応待ち > 完了 > 実行中 > なし」。1 つの tmux セッションで
# 複数の Claude を走らせている場合は、一番手を打つ必要があるものを表示する。
#
# 注意: フックには $TMUX / $TMUX_PANE がそのまま渡る（claude をペインで起動して
# いるため、その子プロセスであるフックが継承する）。実測で確認済み。
set -u

TMUX_BIN=$(command -v tmux 2>/dev/null) || TMUX_BIN=/usr/bin/tmux
[ -x "$TMUX_BIN" ] || exit 0
[ -n "${TMUX:-}" ] || exit 0

STATE="${1:-}"

case "$STATE" in
    busy | waiting | done)
        [ -n "${TMUX_PANE:-}" ] || exit 0
        "$TMUX_BIN" set -p -t "$TMUX_PANE" @cc_state "$STATE" 2> /dev/null
        ;;
    clear)
        [ -n "${TMUX_PANE:-}" ] || exit 0
        "$TMUX_BIN" set -p -t "$TMUX_PANE" -u @cc_state 2> /dev/null
        ;;
    visit)
        # 見に行ったセッションの「完了」は用済みなので落とす。
        # 実行中・対応待ちは残す（見ただけでは解決していない）。
        SESS="${2:-}"
        [ -n "$SESS" ] || exit 0
        "$TMUX_BIN" list-panes -s -t "$SESS" -F '#{pane_id} #{@cc_state}' 2> /dev/null \
            | while read -r pane st; do
                [ "$st" = "done" ] && "$TMUX_BIN" set -p -t "$pane" -u @cc_state 2> /dev/null
            done
        ;;
    *)
        exit 0
        ;;
esac

# --- ペイン単位の状態をセッション単位へ集約する ---
# claude が居ないペインに状態が残っていたら捨てる。フックを飛ばさずに死ぬ経路
# （SIGKILL 等）があるため、既知のシェルが前面に居るペインは無条件で無視する。
# 判定を「シェルなら捨てる」に限定しているのは、未知のコマンド名で誤って
# 状態を消さないようにするため。
"$TMUX_BIN" list-panes -a -F '#{session_name}	#{@cc_state}	#{pane_current_command}' 2> /dev/null \
    | awk -F'\t' '
        {
            st = $2
            if ($3 ~ /^(zsh|bash|sh|dash|fish|tmux|ssh|mosh)$/) st = ""
            p = (st == "waiting" ? 3 : (st == "done" ? 2 : (st == "busy" ? 1 : 0)))
            if (!($1 in best) || p > best[$1]) { best[$1] = p; label[$1] = st }
        }
        END { for (s in best) printf "%s\t%s\n", s, label[s] }
    ' \
    | while IFS='	' read -r sess st; do
        cur=$("$TMUX_BIN" show -t "$sess" -v @cc_status 2> /dev/null)
        [ "$cur" = "$st" ] && continue
        if [ -z "$st" ]; then
            "$TMUX_BIN" set -t "$sess" -u @cc_status 2> /dev/null
        else
            "$TMUX_BIN" set -t "$sess" @cc_status "$st" 2> /dev/null
        fi
    done

# 上段はステータス行ではなくペイン境界線なので、ステータス行だけを更新する
# refresh-client -S ではなく全体の再描画を投げる。
for c in $("$TMUX_BIN" list-clients -F '#{client_tty}' 2> /dev/null); do
    "$TMUX_BIN" refresh-client -t "$c" 2> /dev/null
done

exit 0

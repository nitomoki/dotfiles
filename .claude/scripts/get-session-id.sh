#!/bin/bash
# 現セッションの Claude Code session_id を stdout に出す。
#
# フロー:
#   1. 環境変数 $CLAUDE_SESSION_ID が非空ならそれを出力して exit 0。
#   2. フォールバック: claude-ancestor-pid.sh で自分の祖先にいる claude 本体
#      プロセスの PID を特定し、statusline hook が書いた
#      $BASE/session-map/<pid> を読んで session_id を出力して exit 0。
#   3. どちらも失敗なら stderr にエラーを出し、stdout には何も出さず exit 1。
#
# 注意: Bash ツール内では $CLAUDE_SESSION_ID が空のことがある。その場合に
#   備えて statusline が PID→session_id マップを維持しており、それを引く。
set -uo pipefail

# 1. 環境変数が使えるなら最優先。
if [ -n "${CLAUDE_SESSION_ID:-}" ]; then
  printf '%s\n' "$CLAUDE_SESSION_ID"
  exit 0
fi

# 状態ファイルの固定ベースディレクトリ (hook / skill と共通)。
BASE="/tmp/claude-state-$(id -u)"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANCESTOR_HELPER="$SCRIPT_DIR/claude-ancestor-pid.sh"

# 2. フォールバック: 祖先の claude 本体 PID → session-map を引く。
if [ -x "$ANCESTOR_HELPER" ]; then
  claude_pid="$("$ANCESTOR_HELPER" 2>/dev/null)"
  if [ -n "$claude_pid" ] && [ -f "$BASE/session-map/$claude_pid" ]; then
    sid="$(cat "$BASE/session-map/$claude_pid" 2>/dev/null)"
    if [ -n "$sid" ]; then
      printf '%s\n' "$sid"
      exit 0
    fi
  fi
fi

# 3. どちらも失敗。
echo "get-session-id.sh: session_id を特定できませんでした (CLAUDE_SESSION_ID 未設定かつ session-map 未登録)" >&2
exit 1

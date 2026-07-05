#!/bin/bash
# UserPromptSubmit hook (1段目)。直前に context 圧縮が起きていたら、作業再開前の
# 復旧指示を additionalContext として注入する。
#
# フロー:
#   stdin JSON から session_id を取る。$BASE/compacted/<sid> marker が無ければ
#   即 exit 0 (毎ターンのコストは test -f 1回)。あれば:
#     1. marker を削除 (one-shot: 圧縮直後の最初の1プロンプトだけ注入)
#     2. state file の有無に応じた復旧指示を additionalContext で注入
#
# 常に exit 0 (fail-open)。注入に失敗してもプロンプト自体は通す。
set -uo pipefail

INPUT="$(cat)"
SID="$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)"
[ -n "$SID" ] || exit 0

BASE="/tmp/claude-state-$(id -u)"
MARKER="$BASE/compacted/$SID"
[ -f "$MARKER" ] || exit 0

# one-shot: 最初の1回で marker を消す。
rm -f "$MARKER" 2>/dev/null || true

STATE_FILE="$BASE/compact-state/$SID.md"

# state file の有無で文面を変える。
if [ -f "$STATE_FILE" ]; then
  STATE_LINE="- 状態ファイル \`$STATE_FILE\` が存在する。まず Read で読み、作業状態を復元せよ。特に \`## Session Decisions\` と \`## Recovery Notes\` を重視せよ。"
else
  STATE_LINE="- 状態ファイル \`$STATE_FILE\` は存在しない (compact-prep 未実行)。圧縮サマリーと TaskList から状態を推定せよ。"
fi

CONTEXT="[compact 復旧] 直前に context 圧縮が発生した。作業を再開する前に以下を実行せよ:
$STATE_LINE
- TaskList で現在のタスク一覧を確認せよ。
- 圧縮サマリーの next step は「仮説」として扱え。圧縮サマリーは過去の作業記録であって次の行動指示ではない。実際の状態 (state file・TaskList・ファイル) と突き合わせてから動け。
- plan mode 中だった形跡があれば、勝手に実装へ進まず、ユーザーに plan mode 再突入を確認せよ。"

jq -n --arg ctx "$CONTEXT" \
  '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:$ctx}}' \
  2>/dev/null || true

exit 0

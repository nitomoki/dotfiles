#!/bin/bash
# UserPromptSubmit hook (2段目)。context 使用率が閾値を超えていたら、作業の区切りで
# /compact-prep → /compact を提案するよう additionalContext を注入する。
#
# フロー:
#   stdin JSON から session_id を取る。$BASE/compact-warn/<sid> marker が無ければ
#   即 exit 0。あれば (= statusline が閾値超えを検知):
#     1. 使用率を読む
#     2. warn marker を削除し、warned marker (cooldown) に epoch 秒を書く
#        → 同一セッションで繰り返し促さない。PostCompact で warned は消える。
#     3. /compact-prep を促す指示を additionalContext で注入
#
# 常に exit 0 (fail-open)。
set -uo pipefail

INPUT="$(cat)"
SID="$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)"
[ -n "$SID" ] || exit 0

BASE="/tmp/claude-state-$(id -u)"
WARN="$BASE/compact-warn/$SID"
[ -f "$WARN" ] || exit 0

PCT="$(cat "$WARN" 2>/dev/null)"
[ -n "$PCT" ] || PCT="?"

rm -f "$WARN" 2>/dev/null || true
mkdir -p "$BASE/compact-warned" 2>/dev/null || true
date +%s > "$BASE/compact-warned/$SID" 2>/dev/null || true

CONTEXT="[compact 準備の提案] context 使用率が ${PCT}% に達した。作業の区切りのよいところで、ユーザーに \`/compact-prep\` (セッション状態の保存) → \`/compact\` の実行を提案せよ。scope を縮小したり別セッションに分けたりするのではなく、圧縮前に state を保存する方法で対処せよ。まだ作業の途中で区切りが悪ければ、この提案は次の区切りまで保留してよい。"

jq -n --arg ctx "$CONTEXT" \
  '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:$ctx}}' \
  2>/dev/null || true

exit 0

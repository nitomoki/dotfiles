#!/bin/bash
# PostCompact hook。context 圧縮 (/compact・自動 compact) が発生した直後に起動する。
#
# フロー:
#   stdin JSON から session_id を取り、$BASE/compacted/<sid> に epoch 秒を書く
#   (= 「直近で圧縮された」marker)。次のプロンプト時に UserPromptSubmit hook が
#   これを見て復旧指示を注入する。あわせて compact-warned marker を削除して
#   60% 通知の cooldown をリセットする (圧縮で使用率が下がるため)。
#
# 常に exit 0 (fail-open)。
set -uo pipefail

INPUT="$(cat)"
SID="$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)"
[ -n "$SID" ] || exit 0

BASE="/tmp/claude-state-$(id -u)"
mkdir -p -m 700 "$BASE" 2>/dev/null || exit 0
mkdir -p "$BASE/compacted" "$BASE/compact-warned" 2>/dev/null || exit 0

date +%s > "$BASE/compacted/$SID" 2>/dev/null || true
rm -f "$BASE/compact-warned/$SID" 2>/dev/null || true

exit 0

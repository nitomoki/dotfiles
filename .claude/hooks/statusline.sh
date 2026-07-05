#!/bin/bash
# Claude Code statusline hook。stdin の JSON を読んで1行のステータスを表示しつつ、
# compact 対策の裏方処理を行う。
#
# 表示:
#   <model.display_name> | <current_dir (home は ~ に短縮)> | ctx <used%>%
#   ctx 部分は 60%以上で黄, 80%以上で赤に色付け (それ以外はデフォルト色)。
#   used_percentage が null/欠損なら `ctx --%`。
#
# 裏方処理:
#   1. session-map 更新: 自分の祖先の claude 本体 PID を特定し、
#      $BASE/session-map/<pid> に session_id を書く (同内容なら書かない)。
#      ついでにマップ内の死んだ PID のエントリを掃除する。
#      → Bash ツール内で $CLAUDE_SESSION_ID が空でも get-session-id.sh が
#        この PID→session_id マップから session_id を引けるようにするため。
#   2. 60% warn marker: used_percentage が閾値 (既定60, COMPACT_WARN_THRESHOLD で
#      上書き可) 以上かつ warned marker が無ければ、$BASE/compact-warn/<sid> に
#      使用率整数を書く。UserPromptSubmit hook がこれを見て /compact-prep を促す。
#
# fail-open: どこで失敗してもステータス1行だけは必ず出して exit 0。
set -uo pipefail

INPUT="$(cat)"

# --- JSON 抽出 (jq が無い/壊れた入力でも表示は死なせない) ---
MODEL="$(printf '%s' "$INPUT" | jq -r '.model.display_name // "Claude"' 2>/dev/null)"
[ -n "$MODEL" ] && [ "$MODEL" != "null" ] || MODEL="Claude"
CWD="$(printf '%s' "$INPUT" | jq -r '.workspace.current_dir // ""' 2>/dev/null)"
PCT="$(printf '%s' "$INPUT" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)"
SID="$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)"

# --- current_dir の home を ~ に短縮 ---
DIR_DISP="$CWD"
if [ -n "$CWD" ]; then
  case "$CWD" in
    "$HOME") DIR_DISP="~" ;;
    "$HOME"/*) DIR_DISP="~${CWD#"$HOME"}" ;;
  esac
fi
[ -n "$DIR_DISP" ] || DIR_DISP="?"

# --- ctx 表示文字列 (色付け) ---
THRESHOLD="${COMPACT_WARN_THRESHOLD:-60}"
ESC=$'\033'
RESET="${ESC}[0m"
YELLOW="${ESC}[33m"
RED="${ESC}[31m"

# used_percentage を整数に丸める (小数や null に対応)。
PCT_INT=""
if [ -n "$PCT" ] && [ "$PCT" != "null" ]; then
  PCT_INT="$(printf '%.0f' "$PCT" 2>/dev/null)"
fi

if [ -n "$PCT_INT" ]; then
  if [ "$PCT_INT" -ge 80 ] 2>/dev/null; then
    CTX="${RED}ctx ${PCT_INT}%${RESET}"
  elif [ "$PCT_INT" -ge "$THRESHOLD" ] 2>/dev/null; then
    CTX="${YELLOW}ctx ${PCT_INT}%${RESET}"
  else
    CTX="ctx ${PCT_INT}%"
  fi
else
  CTX="ctx --%"
fi

# --- ステータス1行を出力 (これだけは何があっても出す) ---
printf '%s | %s | %s\n' "$MODEL" "$DIR_DISP" "$CTX"

# ===== 以降は裏方処理。失敗しても exit 0 を保つ =====

BASE="/tmp/claude-state-$(id -u)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd 2>/dev/null)" || SCRIPT_DIR=""
ANCESTOR_HELPER="$SCRIPT_DIR/../scripts/claude-ancestor-pid.sh"

# session_id が取れなければ裏方処理はスキップ (marker/map は sid 依存)。
[ -n "$SID" ] || exit 0

mkdir -p -m 700 "$BASE" 2>/dev/null || exit 0
mkdir -p "$BASE/session-map" "$BASE/compact-warn" "$BASE/compact-warned" 2>/dev/null || exit 0

# --- 1. session-map 更新 ---
if [ -x "$ANCESTOR_HELPER" ]; then
  CLAUDE_PID="$("$ANCESTOR_HELPER" 2>/dev/null)"
  if [ -n "$CLAUDE_PID" ]; then
    MAP_FILE="$BASE/session-map/$CLAUDE_PID"
    # 同内容が既にあれば書き直さない。
    if [ ! -f "$MAP_FILE" ] || [ "$(cat "$MAP_FILE" 2>/dev/null)" != "$SID" ]; then
      printf '%s' "$SID" > "$MAP_FILE" 2>/dev/null || true
    fi
  fi
fi

# 死んだ PID のマップエントリを掃除。
for f in "$BASE"/session-map/*; do
  [ -e "$f" ] || continue
  p="$(basename "$f")"
  case "$p" in
    ''|*[!0-9]*) continue ;;  # 数値以外のファイル名は無視
  esac
  kill -0 "$p" 2>/dev/null || rm -f "$f" 2>/dev/null || true
done

# --- 2. 60% warn marker ---
if [ -n "$PCT_INT" ] && [ "$PCT_INT" -ge "$THRESHOLD" ] 2>/dev/null; then
  if [ ! -f "$BASE/compact-warned/$SID" ]; then
    printf '%s' "$PCT_INT" > "$BASE/compact-warn/$SID" 2>/dev/null || true
  fi
fi

exit 0

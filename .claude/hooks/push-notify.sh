#!/usr/bin/env bash
# Claude Code hook → Moshi push 通知。Notification / Stop / SubagentStop で起動。
# 秘匿情報 (token) は dotfiles に載せず ~/.env から読む。~/.env が無い/未設定の
# マシンでは黙って何もしない (3台共通配布でも安全)。送信は非同期でターンをブロックしない。
#
# Stop 通知の本文は既定で「応答本文の冒頭200字＋メタ行」。~/.env で MOSHI_SUMMARIZE=1 を
# 設定すると、本文冒頭500字を Codex CLI (codex exec) に投げて100字要約に差し替える。
# 軽量モデルを使うなら MOSHI_CODEX_MODEL でモデル名を指定 (未指定なら codex の既定)。
# codex の認証は codex 側 (CODEX_HOME) を利用。要約は detach 側で行いターンをブロックしない。
# codex 失敗/空応答/タイムアウトは必ず本文冒頭表示にフォールバックする。
# 要約をやめたいときは MOSHI_SUMMARIZE を 0/未設定に戻すだけでよい (コード変更不要)。
INPUT="$(cat)"
ENV_FILE="$HOME/.env"
[ -f "$ENV_FILE" ] || exit 0
# shellcheck disable=SC1090
set -a; . "$ENV_FILE"; set +a
[ -n "${MOSHI_TOKEN:-}" ] || exit 0
URL="${MOSHI_WEBHOOK_URL:-https://api.getmoshi.app/api/webhook}"

EVENT="$(printf '%s' "$INPUT" | jq -r '.hook_event_name // "Claude"')"
CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // ""')"
PROJ="$(basename "${CWD:-Claude}")"
TRANS="$(printf '%s' "$INPUT" | jq -r '.transcript_path // ""')"

# --- cwd の git ブランチ (あれば proj@branch 表記に使う) ---
BRANCH=""
if [ -n "$CWD" ] && command -v git >/dev/null 2>&1; then
  BRANCH="$(git -C "$CWD" branch --show-current 2>/dev/null)"
fi
LABEL="$PROJ"
[ -n "$BRANCH" ] && LABEL="$PROJ@$BRANCH"

# --- 文字数トリム (jq: Unicode コードポイント単位でマルチバイト安全に切る) ---
# $1=本文 $2=文字数 $3=超過時に … を付すなら 1
cut_chars() {
  jq -rn --arg s "$1" --argjson n "$2" --argjson e "${3:-0}" \
    '$s | if (.|length) > $n then (.[:$n] + (if $e==1 then "…" else "" end)) else . end'
}

# --- Codex CLI で100字要約 (失敗/タイムアウト時は空文字。呼び出し側で本文にフォールバック) ---
# 入力本文は stdin で渡す (codex は prompt 引数 + stdin を <stdin> ブロックとして扱う)。
# 最終メッセージは -o <file> に書かせて確実に取り出す。read-only / ephemeral で副作用なし。
codex_summarize() {
  local src="$1" out sum model_args=()
  command -v codex >/dev/null 2>&1 || return 0
  [ -n "${MOSHI_CODEX_MODEL:-}" ] && model_args=(-m "$MOSHI_CODEX_MODEL")
  out="$(mktemp 2>/dev/null)" || return 0
  printf '%s' "$src" | timeout "${MOSHI_CODEX_TIMEOUT:-45}" codex exec \
    "${model_args[@]}" -s read-only --ephemeral --skip-git-repo-check --color never \
    -o "$out" \
    "次はコーディングエージェントの応答本文の冒頭 (<stdin>) です。Moshi 通知用に日本語で100字以内・1文で要約してください。要約文だけを返し、前置き・引用符・箇条書き・改行は入れないこと。" \
    >/dev/null 2>&1
  sum="$(tr '\n\r\t' '   ' < "$out" 2>/dev/null | sed 's/  */ /g; s/^ *//; s/ *$//')"
  rm -f "$out"
  printf '%s' "$sum"
}

# --- transcript から「その回の応答本文」(制御文字を空白化・未トリム) と所要時間を取り出す ---
RAWBODY=""
DUR=""
if [ -n "$TRANS" ] && [ -f "$TRANS" ]; then
  RAWBODY="$(jq -rs '
    ([ .[] | select(.type=="assistant")
           | (.message.content // [] | map(select(.type=="text").text) | join(" ")) ]
     | map(select(. != "")) | last // "")
    | gsub("[\n\r\t]+";" ") | gsub("  +";" ")' "$TRANS" 2>/dev/null)"
  # 所要時間: 最後の user → 最後の assistant の時刻差
  U_TS="$(jq -rs '[.[] | select(.type=="user") | .timestamp] | last // empty' "$TRANS" 2>/dev/null)"
  A_TS="$(jq -rs '[.[] | select(.type=="assistant") | .timestamp] | last // empty' "$TRANS" 2>/dev/null)"
  if [ -n "$U_TS" ] && [ -n "$A_TS" ]; then
    US="$(date -d "$U_TS" +%s 2>/dev/null)"
    AS="$(date -d "$A_TS" +%s 2>/dev/null)"
    if [ -n "$US" ] && [ -n "$AS" ] && [ "$AS" -ge "$US" ]; then
      D=$((AS - US))
      if [ "$D" -ge 60 ]; then DUR="$((D/60))m$((D%60))s"; else DUR="${D}s"; fi
    fi
  fi
fi
BODY="$(cut_chars "$RAWBODY" 200 1)"   # フォールバック表示用 (冒頭200字)
CWD_DISP="$(printf '%s' "$CWD" | sed "s#^$HOME#~#")"

# --- イベント別に本文(MSGBODY)・メタ行(MSGMETA)・要約対象(SUMMARY_SRC)を決める ---
SUMMARY_SRC=""
case "$EVENT" in
  Notification)
    NMSG="$(printf '%s' "$INPUT" | jq -r '.message // "入力待ちです"')"
    # 60秒アイドルの汎用催促 ("Claude is waiting for your input") は push しない。
    # permission 承認待ち等の本物の「要対応」だけ通知する。
    [ "$NMSG" = "Claude is waiting for your input" ] && exit 0
    TITLE="Claude: 要対応 ($LABEL)"
    MSGBODY="$NMSG"
    MSGMETA=""
    ;;
  Stop)
    # 応答完了: 本文冒頭(または Haiku 要約) + メタ行 (cwd / 所要時間)
    TITLE="Claude: 応答完了 ($LABEL)"
    MSGBODY="${BODY:-応答が完了しました}"
    MSGMETA=""
    [ -n "$DUR" ] && MSGMETA="――― $CWD_DISP / $DUR"
    # 要約 ON かつ本文があるときだけ冒頭500字を要約対象にする
    if [ "${MOSHI_SUMMARIZE:-0}" = "1" ] && [ -n "$RAWBODY" ]; then
      SUMMARY_SRC="$(cut_chars "$RAWBODY" 500 0)"
    fi
    ;;
  SubagentStop)
    TITLE="Claude: subagent 完了 ($LABEL)"
    MSGBODY="${BODY:-サブエージェントが完了しました}"
    MSGMETA=""
    ;;
  *)
    TITLE="Claude ($LABEL)"
    MSGBODY="$EVENT"
    MSGMETA=""
    ;;
esac

# --- 非同期(detach)で: (要約 ON なら) Haiku 要約 → payload 構築 → 送信 ---
# ターン終了/通知をブロックしない。要約失敗時は MSGBODY (本文冒頭) にフォールバック。
send_notification() {
  local body="$MSGBODY" msg
  if [ -n "$SUMMARY_SRC" ]; then
    local sum; sum="$(codex_summarize "$SUMMARY_SRC")"
    [ -n "$sum" ] && body="$sum"
  fi
  msg="$body"
  [ -n "$MSGMETA" ] && msg="$msg"$'\n'"$MSGMETA"
  local payload
  payload="$(jq -nc --arg t "$MOSHI_TOKEN" --arg ti "$TITLE" --arg m "$msg" \
    '{token:$t,title:$ti,message:$m}')"
  curl -s --max-time 8 -X POST "$URL" -H "Content-Type: application/json" \
    -d "$payload" >/dev/null 2>&1
}
( send_notification >/dev/null 2>&1 & )
exit 0

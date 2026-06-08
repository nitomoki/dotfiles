#!/usr/bin/env bash
# Claude Code hook → Moshi push 通知。Notification / Stop / SubagentStop で起動。
# 秘匿情報 (token) は dotfiles に載せず ~/.env から読む。~/.env が無い/未設定の
# マシンでは黙って何もしない (3台共通配布でも安全)。送信は非同期でターンをブロックしない。
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

case "$EVENT" in
  Notification)
    TITLE="Claude: 要対応"
    MSG="$(printf '%s' "$INPUT" | jq -r '.message // "入力待ちです"') ($PROJ)"
    ;;
  Stop)
    TITLE="Claude: 応答完了"
    MSG="応答が完了しました ($PROJ)"
    ;;
  SubagentStop)
    TITLE="Claude: subagent 完了"
    MSG="サブエージェントが完了 ($PROJ)"
    ;;
  *)
    TITLE="Claude"
    MSG="$EVENT ($PROJ)"
    ;;
esac

PAYLOAD="$(jq -nc --arg t "$MOSHI_TOKEN" --arg ti "$TITLE" --arg m "$MSG" \
  '{token:$t,title:$ti,message:$m}')"
# 非同期送信 (detach): ターン終了/通知をブロックしない
( curl -s --max-time 5 -X POST "$URL" -H "Content-Type: application/json" \
    -d "$PAYLOAD" >/dev/null 2>&1 & )
exit 0

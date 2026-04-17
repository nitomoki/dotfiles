#!/bin/sh
# Per-pane Claude Code agent status icon for tmux window-status-format.
# Reads /tmp/claude-status-<pane_id> populated by Claude Code hooks
# (SessionStart/UserPromptSubmit/Stop/Notification/SessionEnd).
#
# Env: set CLAUDE_STATUS_ASCII=1 to use Unicode fallback icons when
# Nerd Font glyphs are unavailable.

pane_id="$1"
[ -z "$pane_id" ] && exit 0

status=$(cat "/tmp/claude-status-${pane_id}" 2>/dev/null)
[ -z "$status" ] && exit 0

if [ -n "$CLAUDE_STATUS_ASCII" ]; then
  running_icon='●'
  waiting_icon='◉'
  idle_icon='○'
else
  running_icon=''  # nf-fa-cog
  waiting_icon=''  # nf-fa-bell
  idle_icon=''   # nf-fa-check
fi

case "$status" in
  running) printf ' #[fg=yellow]%s#[default]' "$running_icon" ;;
  waiting) printf ' #[fg=red,blink]%s#[default]' "$waiting_icon" ;;
  idle)    printf ' #[fg=green]%s#[default]' "$idle_icon" ;;
esac

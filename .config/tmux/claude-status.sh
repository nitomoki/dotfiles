#!/bin/sh
# Per-pane Claude Code agent status icon for tmux window-status-format.
# Reads /tmp/claude-status-<pane_id> populated by Claude Code hooks
# (SessionStart/UserPromptSubmit/Stop/Notification/SessionEnd).
#
# Uses standard Unicode symbols (BMP) by default because tmux drops
# Private Use Area glyphs (Nerd Font) when wcwidth() reports -1.
# Set CLAUDE_STATUS_NERDFONT=1 to use Nerd Font glyphs anyway (works
# outside tmux, or in a tmux built with PUA-aware wcwidth).

pane_id="$1"
[ -z "$pane_id" ] && exit 0

status=$(cat "/tmp/claude-status-${pane_id}" 2>/dev/null)
[ -z "$status" ] && exit 0

if [ -n "$CLAUDE_STATUS_NERDFONT" ]; then
  running_icon=''  # nf-fa-cog
  waiting_icon=''  # nf-fa-bell
  idle_icon=''   # nf-fa-check
else
  running_icon='⚙'  # U+2699 GEAR
  waiting_icon='⚠'  # U+26A0 WARNING SIGN
  idle_icon='✓'     # U+2713 CHECK MARK
fi

case "$status" in
  running) printf '#[fg=yellow][%s]#[default]' "$running_icon" ;;
  waiting) printf '#[fg=black,bg=red,blink][%s]#[default]' "$waiting_icon" ;;
  idle)    printf '#[fg=green][%s]#[default]' "$idle_icon" ;;
esac

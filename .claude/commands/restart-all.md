---
description: tmux 上の全 Claude Code を /restart し、最後にこのセッションも再起動する
allowed-tools: Bash(~/dotfiles/bin/tmux-agents restart-all)
disable-model-invocation: true
---

実行結果:

!`~/dotfiles/bin/tmux-agents restart-all`

上の結果のうち、スキップ・失敗したペインとその理由だけを短く伝えて終わること。無ければ「完了」とだけ返す。ツールは使わない（応答が終わるとこのセッションが自動で再起動するため）。

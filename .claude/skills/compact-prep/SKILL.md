---
name: compact-prep
description: |
  Claude Code の /compact 実行前に、現セッションの作業状態を一時 state file へ保存する。
  MANDATORY TRIGGERS: /compact-prep, compact-prep, 圧縮準備, compact 準備, コンパクト準備, 圧縮前状態保存。
  DO NOT TRIGGER: compact 後の復旧、通常の進捗報告、plan 作成、context 使用率の雑談。
strict_procedure: true
argument-hint: "[復旧メモ]"
allowed-tools: Read Write Bash(~/.claude/scripts/get-session-id.sh *) Bash(mkdir *) Bash(date *) Bash(pwd)
---

# compact-prep

Claude Code の `/compact` 前に、圧縮サマリーへ残りにくい作業状態を state file へ保存する。

## Strict procedure profile

- Strictness: strict-procedure。圧縮前 state file の内容と保存完了報告が成果そのもの。
- Hard gates: session_id が取得できない場合は state file を推測名で作らず、取得不能として停止する。
- Forcing function: 保存先パスを固定し、保存後にファイルを読み返して必須項目の有無を確認する。
- Completion receipt: state file パス、保存した主要項目、未確認項目、次に実行する `/compact` 案内を報告する。

## 手順

1. session_id を取得する。
   - `~/.claude/scripts/get-session-id.sh` を実行する。出力された値を `SESSION_ID` とする。
   - 取得できない (exit 1 / 空出力) 場合は state file を作らず、session_id が取得できないため準備未完了と報告する。
2. 保存先を決める。
   - 保存先は `/tmp/claude-state-$(id -u)/compact-state/${SESSION_ID}.md` とする。
   - 親ディレクトリを `mkdir -p -m 700 /tmp/claude-state-$(id -u)/compact-state` で用意する。
3. TaskList、plan 状態、並走 worker、編集中ファイルを確認する。
4. state file に以下の見出しをこの順で保存する。
   - `# Compact Prep State`
   - `## Active Plan`
   - `## Current Phase`
   - `## TaskList Summary`
   - `## Session Decisions`
   - `## Constraints and Blockers`
   - `## Worker Topology`
   - `## Editing Files`
   - `## Recovery Notes`
5. 保存後に state file を読み直し、上記見出しがすべて存在することを確認する。
6. ユーザーに「準備完了。`/compact` を実行してください。」と伝える。

## 保存内容

- **Active Plan**: plan mode 中なら plan の内容と現在フェーズ/ステップを記録。plan file が無ければ、会話中に合意した方針・段取りを書く。
- **Current Phase**: 今どのフェーズ/ステップを進めているか。
- **TaskList Summary**: in-progress タスク一覧と補足。
- **Session Decisions**: session 中の判断、ユーザーの選択、不採用にした案とその理由。
- **Constraints and Blockers**: 制約、ブロッカー、未完了の検証。
- **Worker Topology**: 並走 worker (tmux の別 pane、バックグラウンドジョブ、サブエージェント等) があれば記録。無ければ「無し」と明記する。
- **Editing Files**: 編集中のファイルと、未保存または未検証の注意点。
- **Recovery Notes**: 圧縮後の自分への復旧メモ。何を仮説として疑うべきか、次に何を確認すべきか。

## Completion receipt

完了時は次を含める。

- state file パス
- 保存した主要項目
- 未確認項目と理由
- `準備完了。/compact を実行してください。`

# compact-state: context 圧縮対策一式

Claude Code の context 圧縮 (`/compact`・自動 compact) では、圧縮サマリーに「判断構造・セッション状態」が残りきらず、再開後に誤動作することがある。これを防ぐための skill + hook + statusline 一式。

## 3 つの構成要素

1. **compact-prep skill** — `/compact` の**前**にユーザーが叩き、セッション状態を state file へ保存する。
2. **PostCompact + UserPromptSubmit の2段 hook** — 圧縮の発生を marker で記録し、次のプロンプト時に `additionalContext` で復旧指示を注入する。
3. **60% 通知** — statusline hook が context 使用率の閾値超えで warn marker を書き、UserPromptSubmit hook が `/compact-prep` の実行提案を注入する。

## marker フロー (テキスト図)

```
[通常運転]
  statusline.sh (毎描画)
    ├─ session-map/<claude_pid> ← session_id を記録 (get-session-id 用)
    └─ 使用率 ≥ 閾値 かつ 未通知 → compact-warn/<sid> を書く
                                      │
  UserPromptSubmit: compact-prep-reminder.sh (毎プロンプト)
    compact-warn/<sid> あり → 消費し compact-warned/<sid> を書く
                            → 「/compact-prep を提案せよ」を注入
                                      │
[ユーザーが /compact-prep 実行]
  compact-prep skill → compact-state/<sid>.md を保存
                                      │
[ユーザーが /compact 実行 → 圧縮発生]
  PostCompact: compaction-recovery.sh
    ├─ compacted/<sid> ← epoch を書く
    └─ compact-warned/<sid> を削除 (通知 cooldown リセット)
                                      │
[圧縮後、最初のプロンプト]
  UserPromptSubmit: compaction-recovery.sh
    compacted/<sid> あり → 消費 (one-shot)
                         → 「state file を読め / TaskList 確認 / サマリーの
                            next step は仮説扱い / plan mode 再突入確認」を注入
```

## ファイルの役割

| ファイル | 種別 | 役割 |
|---|---|---|
| `.claude/scripts/claude-ancestor-pid.sh` | 共通ヘルパ | 祖先を辿り claude 本体プロセス (`/share/claude/versions/`) の PID を返す |
| `.claude/scripts/get-session-id.sh` | 共通ヘルパ | `$CLAUDE_SESSION_ID` → session-map の順で session_id を解決 |
| `.claude/hooks/statusline.sh` | statusLine | ステータス1行表示 + session-map 更新 + warn marker |
| `.claude/hooks/compaction-recovery.sh` | PostCompact | 圧縮発生を `compacted` marker に記録、`compact-warned` をリセット |
| `.claude/hooks/userpromptsubmit-compaction-recovery.sh` | UserPromptSubmit | 圧縮直後の1プロンプトに復旧指示を注入 |
| `.claude/hooks/userpromptsubmit-compact-prep-reminder.sh` | UserPromptSubmit | 使用率超過時に `/compact-prep` 提案を注入 |
| `.claude/skills/compact-prep/SKILL.md` | skill | `/compact` 前に state file を保存 |

## 状態ファイル・marker 一覧

ベースディレクトリは固定で `BASE=/tmp/claude-state-$(id -u)` (`mkdir -p -m 700`)。hook と skill 内 Bash で `$TMPDIR` が食い違うのを避けるため固定パスにしている。

| パス | 書き手 | 読み手 | 中身 |
|---|---|---|---|
| `$BASE/compact-state/<sid>.md` | compact-prep skill | compaction-recovery (UPS) | 保存したセッション状態 (Markdown) |
| `$BASE/compacted/<sid>` | compaction-recovery (PostCompact) | compaction-recovery (UPS) | 圧縮時の epoch 秒 (one-shot marker) |
| `$BASE/compact-warn/<sid>` | statusline | compact-prep-reminder (UPS) | 使用率の整数 |
| `$BASE/compact-warned/<sid>` | compact-prep-reminder | statusline (抑止判定) | 通知済み epoch 秒 (cooldown)。PostCompact で削除 |
| `$BASE/session-map/<claude_pid>` | statusline | get-session-id | session_id |

`<sid>` = session_id。`<claude_pid>` = claude 本体プロセスの PID。

## session_id の解決方法

Bash ツール内では `$CLAUDE_SESSION_ID` が**空のことがある**。そのため:

1. `$CLAUDE_SESSION_ID` が非空ならそれを使う。
2. 空なら、自プロセスの祖先を辿って claude 本体プロセス (`/share/claude/versions/`) の PID を特定し、statusline が書いておいた `session-map/<pid>` から session_id を引く。

statusline は毎描画で session-map を更新し、死んだ PID のエントリも掃除する。

## デプロイ手順と注意点

デプロイは `make` (= `make deploy`)。`.claude/*` の各エントリが `~/.claude/` 配下へ symlink される (`ln -sfn`)。`claude/settings.json` は別途 `~/.claude/settings.json` へ symlink される。

**注意点:**

- **NucBox では `~/.claude/skills/` が実体の空ディレクトリとして既に存在するため、`ln -sfn` が既存ディレクトリを上書きできず失敗する。**先に `rmdir ~/.claude/skills` してから `make` すること。skills/ 配下に実体ファイルを置いている場合は退避してから。
- `~/.claude/scripts/` も同様に、既存の実体ディレクトリがあれば `rmdir` / 退避してから `make` すること。
- `~/.claude/hooks/` は既に symlink 運用中 (push-notify.sh) なので通常は問題ない。
- **60% という閾値は 1M context 前提。**200K context のモデル/プランでは 60% で頻繁に鳴りすぎるので、`COMPACT_WARN_THRESHOLD=80` 等に上げること。statusline の環境変数で上書きできる (`settings.json` の `env` か shell 環境で設定)。
- 3台共通配布 (Windows/WSL2/Nucbox)。`/tmp/claude-state-$(id -u)` はマシンローカルなので、marker がマシンをまたぐことはない。

## デプロイ後の確認

```sh
ls -l ~/.claude/hooks/statusline.sh ~/.claude/scripts/get-session-id.sh
readlink ~/.claude/settings.json
jq . ~/.claude/settings.json >/dev/null && echo settings-ok
```

statusline が出ること、context 使用率が表示されることを確認する。使用率が閾値を超えたら次のプロンプトで `/compact-prep` 提案が入る。

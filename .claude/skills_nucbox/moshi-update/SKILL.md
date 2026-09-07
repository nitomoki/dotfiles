---
name: moshi-update
description: moshi-hook（Moshi の CLI + 常駐デーモン）を最新リリースに更新する。「moshi をアップデートして」「moshi-hook のバージョンを上げたい」「Moshi の通知が来ない / デーモンが古いかも」「moshi のバージョン確認」等で使う。バージョン確認 → 更新 → デーモン再起動 → 検証 → hook 設定の dotfiles 同期まで。
---

# moshi-hook のアップデート

Moshi は「iPhone アプリ」と「PC 側の moshi-hook」の2つで構成される。**このスキルが扱うのは PC 側の moshi-hook だけ**。
iPhone アプリ本体の更新は App Store から行う（このスキルの範囲外）。

## 前提の確認

```sh
hostname                  # どのマシンか（tomoki-NucBox-G10 = NucBox）
command -v moshi moshi-hook
```

- `~/.local/bin/moshi` は `moshi-hook` への symlink。どちらを叩いても同じバイナリ。
- 単一の静的リンク Go バイナリ。`~/.local/bin/` 配下なので **sudo は不要**。
- ペアリング情報は `~/.local/state/moshi/secrets.json`、設定は `~/.config/moshi/config.toml` に永続化される。更新で消えないので **再ペアリングは不要**。

## 手順

### 1. 現在版と最新版を比較

```sh
moshi-hook version
curl -fsS https://cdn.getmoshi.app/hook/latest/version.txt
```

同じなら更新不要。ここで打ち止めにしてよい。

### 2. 更新

```sh
moshi update
```

- `moshi update` は `moshi-hook update` のこと。tar.gz を落として `~/.local/bin/moshi-hook` を置き換える。
- 特定バージョンを入れる／切り戻す場合は `moshi update --version v0.2.78`。

### 3. デーモンを再起動する（Linux では必須）

更新はバイナリを置き換えるだけで、**常駐中のデーモンは古いプロセスのまま動き続ける**。
このバージョンの `moshi-hook service` には `restart` サブコマンドが無い（`install` / `status` / `uninstall` のみ）ので、systemd で再起動する。

```sh
systemctl --user restart moshi-hook.service
```

ユニットは `~/.config/systemd/user/moshi-hook.service`（`moshi-hook service install` が生成したもの。dotfiles 管理外）。
サービス化していないマシンで手動起動している場合は、`pkill -TERM -f 'moshi(-hook)? serve'` してから `moshi serve &` で起こし直す。

### 4. 検証

```sh
moshi-hook version
systemctl --user status moshi-hook.service --no-pager
rg -N 'starting moshi-hook daemon' ~/.local/state/moshi/hook.log | tail -1
moshi-hook status
```

チェックポイント:

- ログ最終行の `version=` が **入れたバージョンと一致**していること（ここが古いままなら再起動できていない）
- `systemctl` が `active (running)`
- `moshi-hook status` が `status: paired` で、`hooks:` の `codex` が `current`

`hooks:` に `stale` や `missing` が出たら次へ進む。出ていなければ完了。

#### `claude   stale` は誤検出（v0.3.19 で確認・2026-09-07）

v0.3.19 の status は hook コマンドを**完全一致**で照合するようになった。
dotfiles で使っている guarded 形式（手順 5 参照）は install が書く絶対パス形式と
文字列が違うため、**中身が最新でも必ず `stale` と判定される**。

```
claude   stale    missing: Notification entries outdated, PermissionRequest entries outdated,
                           PostToolUse entries outdated, PreToolUse entries outdated, ...
```

このように **全イベントが一斉に `outdated` で並ぶのが誤検出のサイン**。通知そのものは正常に動くので無視してよい。
（本当に定義が増えたときは一部のイベントだけが挙がる、とは限らないので、この見た目だけでは断定しないこと。）

hook 定義が実際に増減したかは status では判定できない。確かめるなら手順 5 の
`moshi-hook install` → 構造化 diff で実差分を見る。**差分が「絶対パス化」だけなら実質変更なし**で、
dotfiles を触る必要は無い。

### 5. hook 設定が更新された場合の dotfiles 同期（重要）

`moshi-hook install` は Claude 用の hook を `~/.claude/settings.json` に直接書き込む。
しかし `~/.claude/settings.json` の**正本は `~/dotfiles/claude/settings.dotfiles.json`** で、`make deploy` が

```
jq -s '.[1] + (.[0] | {model, effortLevel})' ~/.claude/settings.json settings.dotfiles.json
```

でマージする。つまり **ローカルに保全されるのは `model` と `effortLevel` だけ**で、`hooks` は dotfiles 側の内容で上書きされる。

→ `moshi-hook install` を実行したら、必ず差分を dotfiles に取り込むこと。
これを怠ると、次の `make deploy` で hook が古い定義に巻き戻り、通知が壊れる。

取り込みは **guarded 形式へ書き戻す → 構造化 diff で実差分を見る → dotfiles の `hooks` を差し替える**
の順で行う（以下）。素の `diff <(jq -S '.hooks' ...)` は並び順ノイズで実差分が埋もれるので使わない。

#### guarded 形式に書き戻してから取り込む（必須）

dotfiles の moshi hook は「バイナリが存在すれば exec する」guarded 形式で収録する。

```json
"command": "if [ -x \"$HOME/.local/bin/moshi-hook\" ]; then exec \"$HOME/.local/bin/moshi-hook\" claude-hook; fi"
```

この形なら moshi を入れていないマシンに配っても無害だし、`$HOME` 依存なのでユーザー名が違っても壊れない。

ところが **`moshi-hook install` は絶対パス直書きで書き出す**（v0.3.19 で確認）。

```json
"command": "'/home/tomoki/.local/bin/moshi-hook' claude-hook"
```

このまま dotfiles に入れると、moshi 未導入マシンでは hook が毎回 exit 127 で失敗し、
ユーザー名が `tomoki` でないマシンでは確実に壊れる。**取り込む前に必ず guarded 形式へ戻すこと。**

```sh
S="${TMPDIR:-/tmp}"   # Claude Code はスクラッチパッドを使うこと
GUARD='if [ -x "$HOME/.local/bin/moshi-hook" ]; then exec "$HOME/.local/bin/moshi-hook" claude-hook; fi'

jq --arg g "$GUARD" '
  (.hooks[][].hooks[]
   | select(.command | (contains("moshi-hook") and (startswith("if [") | not)))
   | .command) |= $g
' ~/.claude/settings.json > "$S/settings.guarded.json"
```

冪等なので、既に guarded 形式なら何も変わらない。書き戻したら live にも反映する
（`cp` は `cp -i` エイリアスで対話待ちになり無言で中断されるため **`command cp -f`** を使う）。

```sh
command cp -f "$S/settings.guarded.json" ~/.claude/settings.json
```

#### 差分は構造化して見る

`moshi-hook install` は各イベント配列内のエントリ順を入れ替えるので、素の `diff` は
並び順ノイズだらけになり実差分が埋もれる。`(イベント, matcher, async, command)` に潰してソートすること。

```sh
flat() { jq -r '.hooks | to_entries[] | .key as $ev | .value[]
  | (.matcher // "*") as $m | .hooks[]
  | "\($ev)\t\($m)\tasync=\(.async)\t\(.command)"' "$1" | sort; }

diff <(flat ~/dotfiles/claude/settings.dotfiles.json) <(flat ~/.claude/settings.json)
```

実差分があれば dotfiles の `hooks` を差し替えてコミットする。

```sh
jq --slurpfile live ~/.claude/settings.json '.hooks = $live[0].hooks' \
   ~/dotfiles/claude/settings.dotfiles.json > "$S/settings.dotfiles.new.json"
python3 -c "import json;json.load(open('$S/settings.dotfiles.new.json'))"   # 壊れていないか確認
command cp -f "$S/settings.dotfiles.new.json" ~/dotfiles/claude/settings.dotfiles.json
```

deny-grep（PreToolUse / Bash）や cc-status.sh の hook が消えていないことを
`git diff` で必ず確認してからコミットすること。

## 落とし穴

- **バイナリだけ更新してデーモンを再起動し忘れる**。一番多い。ログの `version=` で必ず確認する。
- **`moshi-hook install` 後に dotfiles へ同期し忘れる**（上記 5）。
- `moshi-hook set` でブール設定を変えたときも再起動が必要（`scan-ports` は次回の discovery で反映）。
- 更新で挙動が壊れたときは `moshi update --version <直前の版>` で切り戻せる。直前の版はログの `starting moshi-hook daemon` 履歴から辿れる。

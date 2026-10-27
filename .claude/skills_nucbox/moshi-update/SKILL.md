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
- v0.4 系では `moshi-hook doctor` がホスト全体の健全性チェック（デーモン・gateway・tmux/herdr・agent hook・ペアリング）を担う。hook の状態は `status` ではなく `doctor` で見る（手順 4）。

## 手順

0.4.26 → v0.4.38 の更新（2026-10-27）では、手順 1〜4 がこのとおりに通った。

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
v0.4 系では `moshi update` の出力末尾にも `The moshi-hook daemon is running. Restart it to use the updated binary.` と出る。

```sh
moshi-hook service restart
```

- `restart` は v0.4 系で追加された（`install` / `restart` / `status` / `uninstall`）。出力は `Restarted moshi-hook.service`。
- **ユニットファイルは再生成されない**（v0.4.18 で実行前後を比較し、内容も mtime も不変だった・2026-10-07）。
- 0.3.x には `restart` が無い（切り戻した場合など）。そのときは systemd を直接叩く: `systemctl --user restart moshi-hook.service`。v0.4 系でもこちらで同じように再起動できる。

ユニットは `~/.config/systemd/user/moshi-hook.service`（`moshi-hook service install` が生成したもの。dotfiles 管理外）。
サービス化していないマシンで手動起動している場合は、`pkill -TERM -f 'moshi(-hook)? serve'` してから `moshi serve &` で起こし直す。

### 4. 検証

```sh
moshi-hook version
systemctl --user status moshi-hook.service --no-pager
rg -N 'starting moshi-hook daemon' ~/.local/state/moshi/hook.log | tail -1
moshi-hook status
moshi-hook doctor --json </dev/null \
  | jq -r '.checks[] | "\(.group)\t\(.subject)\t\(.status)\t\(.detail)"'
```

チェックポイント:

- ログ最終行の `version=` が **入れたバージョンと一致**していること（ここが古いままなら再起動できていない）
- `systemctl` が `active (running)`
- `moshi-hook status` が `status: paired`（v0.4 系の `status` には `hooks:` 欄が無い。hook は `doctor` で見る）
- `doctor` の `Host` グループで `daemon` と `gateway` が `ok`（`gateway` の detail に `daemon 0.4.18` のようにデーモンの版も出る）
- `doctor` の `Agents` グループで `codex` が `ok` / `hooks current`

`Agents` の `claude` が `fail` / `hooks out of date` になるのは想定どおりで、直さない（下記の誤検出と採用見送り）。
`codex` など他の agent が `fail` / `warn` なら、その hook は本当に古い。`moshi-hook install --target <agent>` で入れ直す
（codex の設定は dotfiles 管理外なので同期は不要）。
`claude` の hook 定義が本当に変わったかを確かめたいときは手順 5 へ。それ以外は完了。

`Multiplexers` の `herdr` の warn（例: `herdr 0.7.1 predates 0.9; workspaces load through slower fallback calls`）のように、
`doctor` は moshi-hook 更新とは別件の問題も並べる。それらはこのスキルの範囲外。

#### `doctor` は `--json </dev/null` で叩く（`-y` 禁止）

- フラグなしの `moshi-hook doctor` は、見つけた問題の修正（fix）を対話で確認してくる。
- **`--json` は確認だけで何も書き換えない。** `</dev/null` で stdin を塞ぎ、対話待ちにならないようにする。
- **`-y`（`--yes`）は使わないこと。** 下記のとおり `claude` は常に `fail` なので、fix に `moshi-hook install --target claude` が必ず含まれる。
  これが自動で走ると、`~/.claude/settings.json` の moshi hook が絶対パス形式で上書きされ、
  v0.4.38 以降は採用を見送ったプラグインとスキルも live に入る（手順 5 参照）。

#### `claude` の hook 不一致は誤検出（v0.3.19 以降。v0.4.38 でも同じ）

v0.3.19 以降の moshi-hook は、hook コマンドを install が書く絶対パス形式と**完全一致**で照合する。
dotfiles で使っている guarded 形式（手順 5 参照）は文字列が違うため、**中身が最新でも必ず不一致と判定される**。
通知そのものは正常に動くので無視してよい。

v0.4 系（`doctor --json`）での見え方（v0.4.18 で確認・2026-10-07）:

```json
{"group":"Agents","subject":"claude","status":"fail","detail":"hooks out of date","fix":2}
```

- v0.4.38 でも同じ見え方（`fix` の番号だけ `1`・2026-10-27）。ただし v0.4.38 以降のこの `fail` には、
  採用を見送ったプラグインとスキルが入っていないことも含まれる（次節）。
- 連動して `features` の `inbox`（Agent inbox & alerts）と `chat_view`（Chat View）も
  `warn` / `ready for codex; not for claude: hooks out of date` になる。
- `fixes` に `moshi-hook install --target claude` が出るが、実行しない。

0.3.x（`status` の `hooks:` 欄）での見え方（v0.3.19 で確認・2026-09-07）:

```
claude   stale    missing: Notification entries outdated, PermissionRequest entries outdated,
                           PostToolUse entries outdated, PreToolUse entries outdated, ...
```

このように全イベントが一斉に `outdated` で並ぶのが誤検出のサイン。
ただし本当に定義が増えたときに一部のイベントだけが挙がるとは限らないので、見た目だけで断定しないこと。

hook 定義が実際に増減したかは、`status` / `doctor` では判定できない。確かめるなら手順 5 の偽 HOME で
`moshi-hook install --target claude` → guarded 形式へ書き戻し → 構造化 diff で実差分を見る。
**書き戻した後に差分ゼロなら実質変更なし**で、dotfiles を触る必要は無い。

v0.4.18 での実測（2026-10-07）: live の `settings.json` を退避 → `moshi-hook install --target claude`
（出力は `claude -> installed`。相変わらず絶対パス直書き）→ guarded 形式へ書き戻し → 比較した結果、
退避した元の設定とも `settings.dotfiles.json` とも**差分ゼロ**だった。0.3.24 → v0.4.18 で hook 定義は増減していない。
確認後は退避ファイルで live を元に戻した。

v0.4.38 での実測（2026-10-27）: 偽 HOME（手順 5）で `moshi-hook install --target claude` → guarded 形式へ書き戻し →
`norm` で比べた結果、`settings.dotfiles.json` と**差分ゼロ**だった。0.4.26 → v0.4.38 でも hook 定義は増減していない。
`hooks` 以外では `env.CLAUDE_CODE_PLUGIN_DIRS` が増えた（次節）。

#### v0.4.38 で claude の install が増やしたもの（採用見送り）

v0.4.38 の `moshi-hook install --target claude` は、hook に加えて次の 3 つを書き込む（偽 HOME で確認・2026-10-27）。

- `~/.claude/moshi-plugin/`: Claude Code が空のプロンプト欄に薄く出す次の入力候補を、Moshi の Chat View に転送するプラグイン
  - `.claude-plugin/plugin.json`（name `moshi-hook`）、`hooks/hooks.json`（`{ "modules": ["./register.ts"] }`）、`hooks/register.ts` の 3 ファイル。
  - `register.ts` は `prompt.suggest` / `prompt.edit` に乗り、`MoshiPromptSuggestion` / `MoshiPromptSuggestionCleared`
    イベントとして `moshi-hook claude-hook` の stdin に渡す。
  - 呼び出す moshi-hook は絶対パス直書き（`const HELPER = "/home/tomoki/.local/bin/moshi-hook"`）。
    HOME を偽にしても実バイナリのパスになるので、HOME ではなく実行ファイルの位置から決まっている。
- `~/.claude/settings.json` の `env.CLAUDE_CODE_PLUGIN_DIRS`: 上のプラグインの絶対パス（`<HOME>/.claude/moshi-plugin`）。
- `~/.claude/skills/moshi-visuals/SKILL.md`: Claude が `~/.moshi/visuals/` に HTML を書き、Moshi チャットに図表を出すスキル。
  `user-invocable: false` なので、全セッションで Claude の振る舞いが変わる。

**3 つとも採用を見送った**（2026-10-27 判断）。dotfiles にも live にも入れない。live の `~/.claude/` には今どれも無い。

doctor の `claude` 判定は、hook の形式に加えてこの 3 つも全部見ている。偽 HOME に install した直後は
`ok` / `hooks current` だが、次のどれか 1 つを欠いただけで `fail` / `hooks out of date` に戻る（2026-10-27 確認）。

- hook を guarded 形式に戻す
- `moshi-plugin/` を消す
- `env.CLAUDE_CODE_PLUGIN_DIRS` を消す
- `skills/moshi-visuals/` を消す

live は 4 つとも欠いているので、`fail` は想定どおりの状態。`install --target claude` も `doctor -y` も実行しない。

codex 側では、v0.4.38 の `install --target codex` が `~/.codex/skills/moshi-visuals/`（同じスキル）を作る。
`hooks.json` と `config.toml` は mtime が変わるだけで中身は変わらない。doctor の `codex` 判定もこのスキルを見ていて、
消すと `fail` / `hooks out of date` になる（2026-10-27 確認）。codex は dotfiles 管理外なので、入れたままでよく同期も不要。

### 5. hook 設定が更新された場合の dotfiles 同期（重要）

`moshi-hook install` は Claude 用の hook を `~/.claude/settings.json` に直接書き込む。
`--target` を省くと対応する全 agent（codex なども）に書き込むので、Claude の hook だけを確かめるときは
`moshi-hook install --target claude` に絞る。
しかし `~/.claude/settings.json` の**正本は `~/dotfiles/claude/settings.dotfiles.json`** で、`make deploy` が

```
jq -s '.[1] + (.[0] | {model, effortLevel})' ~/.claude/settings.json settings.dotfiles.json
```

でマージする。つまり **ローカルに保全されるのは `model` と `effortLevel` だけ**で、`hooks` は dotfiles 側の内容で上書きされる。

→ `moshi-hook install` を実行したら、必ず差分を dotfiles に取り込むこと。
これを怠ると、次の `make deploy` で hook が古い定義に巻き戻り、通知が壊れる。

取り込みは **guarded 形式へ書き戻す → 構造化 diff で実差分を見る → dotfiles の `hooks` を差し替える**
の順で行う（以下）。素の `diff <(jq -S '.hooks' ...)` は並び順ノイズで実差分が埋もれるので使わない。

#### live で `install --target claude` を実行しない（v0.4.38 以降）

live で実行すると、hook が絶対パス形式になる（下記）だけでなく、手順 4 で採用を見送った 3 つ
（`moshi-plugin/`、`env.CLAUDE_CODE_PLUGIN_DIRS`、`skills/moshi-visuals/`）が live に入る。
下記の jq で guarded 形式に戻しても、直るのは `hooks` だけで 3 つは残る。

- `env.CLAUDE_CODE_PLUGIN_DIRS` は、次の `make deploy` で dotfiles 側の `env` に上書きされて消える。
  プラグインは読み込まれなくなるが、`moshi-plugin/` ディレクトリは残る。
- `skills/moshi-visuals/` は `~/.claude/skills/` 直下に実ディレクトリとして入る（dotfiles のスキルは個別の symlink）。
  `make deploy` が `~/.claude/skills/` から消すのはリンク切れの symlink だけなので、手で消すまで全セッションに効き続ける。

install が何を書くかは、次の偽 HOME で確かめる。

#### 偽 HOME に install して確かめる

live の `settings.json` を偽 HOME にコピーし、そこへ install させる。live の退避と復元が要らず、live は書き換わらない。

```sh
S="${TMPDIR:-/tmp}"   # Claude Code はスクラッチパッドを使うこと
FH="$S/fakehome"; mkdir -p "$FH/.claude"
command cp -f ~/.claude/settings.json "$FH/.claude/settings.json"
HOME=$FH XDG_CONFIG_HOME=$FH/.config XDG_STATE_HOME=$FH/.local/state \
  moshi-hook install --target claude </dev/null

find "$FH" -type f   # install が書いたファイル
diff <(jq -S 'del(.hooks)' ~/.claude/settings.json) <(jq -S 'del(.hooks)' "$FH/.claude/settings.json")   # hooks 以外の変化
```

- v0.4.38 の出力は `claude -> installed`。`find` には `settings.json` のほか、`moshi-plugin/` の 3 ファイルと
  `skills/moshi-visuals/SKILL.md` が出る。`hooks` 以外の変化は `env.CLAUDE_CODE_PLUGIN_DIRS` の追加だけだった。
- 以下の guarded 形式への書き戻し、`flat`、`norm`、dotfiles への差し替えは、`~/.claude/settings.json` をすべて
  `"$FH/.claude/settings.json"` に読み替えればそのまま使える（書き戻しの `cp` 先も偽 HOME にする）。
- live には `cp` しない。実差分があれば dotfiles の `hooks` を差し替え、live へは `make deploy` で配る。
- install と同じ 3 つの環境変数を付けて `moshi-hook doctor --json </dev/null` を叩くと、偽 HOME の状態に対する
  doctor の判定も見られる（手順 4 の判定条件はこれで確かめた）。

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
並び順ノイズだらけになり実差分が埋もれる。`(イベント, matcher, async, timeout, command)` に潰してソートすること。

```sh
flat() { jq -r '.hooks | to_entries[] | .key as $ev | .value[]
  | (.matcher // "*") as $m | .hooks[]
  | "\($ev)\t\($m)\tasync=\(.async)\ttimeout=\(.timeout)\t\(.command)"' "$1" | sort; }

diff <(flat ~/dotfiles/claude/settings.dotfiles.json) <(flat ~/.claude/settings.json)
```

`flat` は上の5項目しか見ない。他のフィールドも含めて厳密に比べるなら、正規化した `hooks` 全体を diff する。

```sh
norm() { jq -S . "$1" | jq -S '.hooks | map_values(map(.hooks |= sort_by(tojson)) | sort_by(tojson))'; }

diff <(norm ~/dotfiles/claude/settings.dotfiles.json) <(norm ~/.claude/settings.json)
```

**`jq -S .` を一度通してから `sort_by(tojson)` すること。** jq の `tojson` / `tostring` はキーの挿入順で
文字列化するので、キー順が違うだけの同じエントリが別物としてソートされ、偽の差分が大量に出る
（`-S` は出力時にしか効かないため、同じ jq の中ではなくパイプの前段で通す）。

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
- **`moshi-hook doctor -y` で誤検出の「修正」を走らせてしまう**。`install --target claude` が走り、hook が絶対パス形式になる（上記 4）。
- **live で `moshi-hook install --target claude` を実行してしまう**。v0.4.38 以降は、採用を見送ったプラグインとスキルも入り、
  guarded 形式に戻しても残る（上記 5）。install の中身は偽 HOME で確かめる。
- `moshi-hook set` でブール設定を変えたときも再起動が必要（`scan-ports` は次回の discovery で反映）。
- 更新で挙動が壊れたときは `moshi update --version <直前の版>` で切り戻せる。直前の版はログの `starting moshi-hook daemon` 履歴から辿れる。

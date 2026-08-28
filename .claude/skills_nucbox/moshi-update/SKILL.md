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
- `moshi-hook status` が `status: paired` で、`hooks:` の `claude` / `codex` が `current`

`hooks:` に `stale` や `missing` が出たら次へ進む。出ていなければ完了。

### 5. hook 設定が更新された場合の dotfiles 同期（重要）

`moshi-hook install` は Claude 用の hook を `~/.claude/settings.json` に直接書き込む。
しかし `~/.claude/settings.json` の**正本は `~/dotfiles/claude/settings.dotfiles.json`** で、`make deploy` が

```
jq -s '.[1] + (.[0] | {model, effortLevel})' ~/.claude/settings.json settings.dotfiles.json
```

でマージする。つまり **ローカルに保全されるのは `model` と `effortLevel` だけ**で、`hooks` は dotfiles 側の内容で上書きされる。

→ `moshi-hook install` を実行したら、必ず差分を dotfiles に取り込むこと。

```sh
# 差分確認
diff <(jq -S '.hooks' ~/dotfiles/claude/settings.dotfiles.json) \
     <(jq -S '.hooks' ~/.claude/settings.json)
```

差分があれば `~/dotfiles/claude/settings.dotfiles.json` の `hooks` を新しい内容に更新し、dotfiles をコミットする。
これを怠ると、次の `make deploy` で hook が古い定義に巻き戻り、通知が壊れる。

なお moshi の hook は「バイナリが存在すれば exec する」形（`if [ -x "$HOME/.local/bin/moshi-hook" ]; then exec ... claude-hook; fi`）なので、
moshi を入れていないマシンに配っても無害。

## 落とし穴

- **バイナリだけ更新してデーモンを再起動し忘れる**。一番多い。ログの `version=` で必ず確認する。
- **`moshi-hook install` 後に dotfiles へ同期し忘れる**（上記 5）。
- `moshi-hook set` でブール設定を変えたときも再起動が必要（`scan-ports` は次回の discovery で反映）。
- 更新で挙動が壊れたときは `moshi update --version <直前の版>` で切り戻せる。直前の版はログの `starting moshi-hook daemon` 履歴から辿れる。

~/dotfiles のメンテナンスとデプロイを以下の手順で実施してください。

## 1. master を最新にする

```
cd ~/dotfiles
git checkout master
git pull origin master
```

## 2. 不要なローカルブランチを削除する

```
git branch --merged master
git branch --no-merged master
```

の両方を確認し、以下のルールに従う。

- `git branch --merged master` に含まれる（マージ済み）かつ `master` 以外のブランチのみ `git branch -d <branch>` で削除する
- `git branch --no-merged master` に含まれる（未マージ）ブランチは **絶対に削除しない**
- `-D` による強制削除は **絶対に使わない**
- 削除対象がなければスキップ

## 3. デプロイ

master ブランチにいることを確認してから実行する。

```
make switch
```

macOS では sudo のパスワードを聞かれる。Nix が無い（`command -v nix` が失敗する）マシンでは実行せず、README のセットアップ手順で Nix を入れるよう報告する。

## 4. ホスト環境に応じた追加の設定

`~/.claude/CLAUDE.md` を参照し、このマシンの環境（WSL2 / Nucbox / Windows ネイティブ / macOS）を判定する。判定結果に応じて以下のいずれかを実行する。

環境別の wezterm 設定（`wezterm_env.lua`）と macOS の terminfo は `make switch` が配る。

- WSL2: **Windows 側にも配布する**。
  - WezTerm GUI 本体は Windows 側で動作しているため、WSL2 側だけでは GUI に反映されない。
  - `ls /mnt/c/Users/` で Windows ユーザー名を確認し、`make setup-wezterm-windows WEZTERM_DIR=/mnt/c/Users/<user>/.config/wezterm` を実行する。
- Nucbox: 追加の設定は無い。
- macOS: 追加の設定は無い（OS 側の設定 `make setup` は新マシンの初回だけでよい）。
- Windows ネイティブ: `make setup-wezterm-windows WEZTERM_DIR=/mnt/c/Users/<user>/.config/wezterm`

`~/.claude/CLAUDE.md` が無い場合は `uname -s` と `hostname` で判定し、不明ならスキップして報告する。

## 5. 完了報告

各ステップの結果（pull の差分、削除したブランチ名、switch の出力）をまとめて報告する。

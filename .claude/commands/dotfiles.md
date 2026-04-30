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

## 3. Linux へのデプロイ

master ブランチにいることを確認してから実行する。

```
make deploy
```

## 4. ホスト環境に応じた wezterm 設定のデプロイ

`~/.claude/CLAUDE.md` を参照し、このマシンの環境（WSL2 / Nucbox / Windows ネイティブ）を判定する。判定結果に応じて以下のいずれかを実行する。

- WSL2: `make setup-wezterm-wsl2`
- Nucbox: `make setup-wezterm-nucbox`
- Windows ネイティブ: `make setup-wezterm-windows WEZTERM_DIR=/mnt/c/Users/<user>/.config/wezterm`

`~/.claude/CLAUDE.md` が無い場合は `hostname` で判定し、不明ならスキップして報告する。

## 5. 完了報告

各ステップの結果（pull の差分、削除したブランチ名、deploy の出力）をまとめて報告する。

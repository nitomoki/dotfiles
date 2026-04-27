# dotfiles

Linux (Ubuntu / WSL2) 環境向けの個人 dotfiles。`make` でシンボリックリンクを張り、`packages.txt` を真実の情報源として apt パッケージを管理する。

## 構成

```
.
├── .zshrc, .gitignore, .latexmkrc, .nethackrc   # $HOME 直下に配置
├── .config/                                     # ~/.config 以下にリンク
│   ├── nvim/        # Neovim 設定 (init.lua + lua/)
│   ├── sheldon/     # zsh プラグインマネージャ
│   ├── tmux/        # tmux.conf と claude-status.sh
│   ├── wezterm/     # 環境別 (wsl2 / nucbox / windows) 設定あり
│   ├── polybar/, stylua/
│   └── systemd/     # ユーザユニット (obsidian.service など)
├── .claude/         # Claude Code 設定 (settings.json)
├── zsh/             # alias.zsh など .zshrc から読み込まれる断片
├── etc/init/        # 新マシン初期セットアップスクリプト群
├── doc/             # 設定の参考資料
├── packages.txt     # apt で永続的にインストールするパッケージ一覧
├── packages-ignore.txt  # packages-diff で無視するパッケージ
└── Makefile
```

## セットアップ

新マシンでの初回:

```sh
git clone https://github.com/nitomoki/dotfiles.git ~/dotfiles
cd ~/dotfiles
make packages-install   # packages.txt を apt でインストール
make deploy             # シンボリックリンクを配置
make init               # etc/init/*.sh を順次実行 (任意)
```

WezTerm を使う環境では、続けて環境別の設定を 1 つ選択する:

```sh
make setup-wezterm-wsl2        # WSL2 (Linux 側)
make setup-wezterm-nucbox      # Nucbox (ベアメタル Linux)
make setup-wezterm-windows WEZTERM_DIR=/mnt/c/Users/<user>/.config/wezterm
```

`wezterm_env.lua` は `.gitignore` 済みで、上記コマンドで machine-local なリンク／コピーが作られる。

## Makefile ターゲット

```
make help                # ヘルプを表示
make deploy              # シンボリックリンクを作成
make test                # deploy で作成されるリンクを dry-run 表示
make init                # etc/init/*.sh を順次実行
make packages-install    # packages.txt のパッケージを apt でインストール
make packages-diff       # apt-mark showmanual と packages.txt の差分を表示
make setup-wezterm-*     # 環境別の wezterm 設定をリンク／コピー
```

`make deploy` は冪等で、既存リンクは `ln -sfnv` で張り直される。`.config/systemd/user/` だけは他アプリの管理ファイルが混ざる場所なので、Makefile の `SYSTEMD_USER_FILES` で個別管理しているユニット (例: `obsidian.service`) のみリンクされる。

## パッケージ管理

- `packages.txt` を編集 → `make packages-install` で反映。
- 追加で手動インストールしたものを把握するには `make packages-diff`。
  - `packages.txt にない手動インストール済` と `packages.txt にあるが未インストール` の双方向の差分を出す。
  - Ubuntu base / kernel など追跡したくないものは `packages-ignore.txt` に書く。
- apt source / `.deb` / snap が必要なもの (gh, tailscale, wezterm, obsidian, steam-launcher など) は `packages.txt` に載せていてもインストール経路が別なことがある。
- Neovim をソースからビルドする際の依存と手順は `etc/init/neovim.sh` 側で扱う。

## ワークフロー

- 修正は必ず作業ブランチで行い、`master` には直接コミットしない。
- 完了したら `origin` に push し、PR 経由で `master` にマージする。

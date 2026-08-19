# dotfiles

Linux (Ubuntu / WSL2) 環境向けの個人 dotfiles。`make` でシンボリックリンクを張り、`packages.txt` をもとに apt パッケージを管理する。

## 構成

```
.
├── .zshrc, .gitignore, .latexmkrc, .nethackrc   # $HOME 直下に配置
├── .config/                                     # ~/.config 以下にリンク
│   ├── nvim/        # Neovim 設定 (init.lua + lua/)
│   ├── sheldon/     # zsh プラグインマネージャ
│   ├── tmux/        # tmux.conf
│   ├── wezterm/     # 環境別 (wsl2 / nucbox / windows) 設定あり
│   ├── polybar/, stylua/
│   └── systemd/     # ユーザユニット (obsidian.service など)
├── .claude/         # Claude Code の CLAUDE.md / hooks / skills / commands
├── claude/          # ~/.claude/settings.json へ jq でマージする共有設定
├── bin/             # 補助スクリプト (.zshrc が PATH に追加する)
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
make setup-wezterm-nucbox      # Nucbox (Linux)
make setup-wezterm-windows WEZTERM_DIR=/mnt/c/Users/<user>/.config/wezterm
```

`wezterm_env.lua` は `.gitignore` 済みで、上記コマンドで machine-local なリンク／コピーが作られる。

## WezTerm から画像を渡す (Alt+i)

Windows のクリップボードにある画像を保存し、その絶対パスを端末にタイプする。Nucbox の Claude Code のようにリモートで動くプログラムへ画像を渡すための経路。

| キー | 置き先 | タイプされるパス |
| --- | --- | --- |
| `Alt+i` | `$WEZTERM_IMGPASTE_HOST` (既定 `nucbox`) | リモートの絶対パス |
| `Alt+Shift+i` | WSL2 ローカル | WSL2 の絶対パス |

リモートのプロセスは Windows のクリップボードを見られない（読めるのは自分が動いているマシンのクリップボードだけ）ので、`Ctrl+V` での画像貼り付けは原理的に成立しない。そこで画像そのものは端末を通さず `ssh` で送り、mosh / et のセッションには「保存先パスの文字列」だけを流す。

- 実体は `bin/wezterm-imgpaste`（WSL2 上で動き、`powershell.exe` でクリップボードを読む）とキーバインド定義の `.config/wezterm/wezterm_windows.lua`。
- 保存先は両側とも `${XDG_CACHE_HOME:-~/.cache}/wezterm-imgpaste/` で、新しい 50 件だけ残して間引かれる。
- 置き先は自動判定しない。ペインの前面プロセス名からの推測は et / tmux 越しだと当てにならず、外すと存在しないパスを黙って打ち込むことになるため、キーで明示する。
- Explorer でコピーしたファイルも同じキーで送れる（1 つ目のみ、32 MiB まで）。
- キーバインドは Windows 環境のみ。環境別設定から共通の `keys` を潰さずに追加するため、`wezterm_windows.lua` は `extra_keys` で渡し、`wezterm.lua` 側で結合している。

## tmux セッションの切り替え (prefix + Space)

ゲーム / 仕事 / HTB / 小説 のようにテーマごとに tmux セッションを分け、それを横断するための仕組み。

| キー | 動作 |
| --- | --- |
| `prefix + Space` | fzf の popup でセッションを選択。一覧に無い名前を入力して Enter すると、その名前でセッションを新規作成して切り替える |
| `prefix + Tab` | 直前のセッションへトグル |
| `prefix + S` | 組み込みの `choose-tree`（fzf / スクリプトが無い環境でも動く保険） |

tmux 既定の `prefix + s` (choose-tree) と `prefix + L` (last-session) は、この設定では `split-window` / `resize-pane` に割り当て済みで潰れている。上記はその代替。

popup の中身は `bin/tmux-sessionizer`。シェルから直接呼んでもよい。

```sh
t                       # fzf で選択（tmux の外からなら attach）
tc <TAB>                # 候補から選ぶ（起動中のセッション + 未起動のプリセット）
tc htb                  # そのセッションへ移動、無ければ作成
tc                      # 引数なしは従来どおり shell セッション
ta <TAB>                # attach 用。起動中のセッションのみ補完する
tmux-sessionizer add reading   # プリセットに追加
tmux-sessionizer del novel     # プリセットから削除（起動中セッションは消さない）
tmux-sessionizer list / edit   # プリセットの表示 / $EDITOR で編集
```

`t` / `tc` は tmux の中から呼べば `switch-client`、外から呼べば `attach-session` になる（`tmux new -A -s` は前者の用途に使えないため）。実体は `tmux-sessionizer switch <name>`。

zsh の補完定義は `zsh/tmux.zsh` に置いている。`compdef` は `compinit` の後でないと使えず、sheldon は `zsh/*.zsh` をアルファベット順に読むため、`compinit` を実行する `config.zsh` より後ろに来る名前にする必要がある（`alias.zsh` に書くと読み込み順が逆になり動かない）。

fzf の中では `ctrl-a` で入力中の名前（空なら選択行）をプリセットへ追加、`ctrl-x` で選択行をプリセットから削除できる。一覧の `●` は起動中のセッション、`○` はプリセットのみ（未起動）。

プリセットの実体は `~/.config/tmux/sessions`（`$TMUX_SESSIONS_FILE` で変更可）。**dotfiles には含めないローカルファイル**で、初回実行時に既定のテーマで自動生成される。マシンごとにテーマが違うため共有していない。

現在のセッション名はステータスラインの左端（マシン名の隣）に表示される。

WezTerm の launch menu の「(tmux)」系エントリも固定セッションではなくこのピッカーを開く。`zsh -lc` は `.zshrc` を読まないため zsh 関数 `t` は使えず、PATH も通らないので `~/dotfiles/bin/tmux-sessionizer` をフルパスで起動している。

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

`make deploy` はリンク配置に加えて `sheldon lock` も実行する。sheldon の lock ファイルには `zsh/*.zsh` を展開した結果のファイル一覧が焼き込まれており、lock が作り直されるのは `plugins.toml` が変わったときだけ。`zsh/` にファイルを新規追加しても `plugins.toml` は無変更なので、lock を再生成しない限り新しいファイルは永久に読み込まれない (`zsh/tmux.zsh` 追加時にこれで `tc` が壊れた)。

## パッケージ管理

- `packages.txt` を編集 → `make packages-install` で反映。
- 追加で手動インストールしたものを把握するには `make packages-diff`。
  - `packages.txt にない手動インストール済` と `packages.txt にあるが未インストール` の差分を出す。
  - Ubuntu base / kernel など追跡したくないものは `packages-ignore.txt` に書く。
- apt source / `.deb` / snap が必要なもの (gh, tailscale, wezterm, obsidian, steam-launcher など) は `packages.txt` に載せていてもインストール経路が別なことがある。
- Neovim をソースからビルドする際の依存と手順は `etc/init/neovim.sh` 側で扱う。


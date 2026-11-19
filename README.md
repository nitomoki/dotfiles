# dotfiles

Linux (Ubuntu / WSL2) と macOS 向けの個人 dotfiles。[Nix](https://nixos.org) の flake と [home-manager](https://github.com/nix-community/home-manager) で、設定ファイルの配布と共通の CLI ツールを Mac と Linux の両方に同じ定義から入れる。GUI アプリや OS に密着したものは、Linux では `packages.txt` (apt)、macOS では `Brewfile` (Homebrew) で管理する。

## 構成

```
.
├── flake.nix, flake.lock   # マシンごとの home-manager 設定 (mac / nucbox / wsl2)
├── nix/home.nix     # 配布するファイルと Nix で入れるパッケージ
├── .zshenv, .zshrc, .zlogin, .gitignore, .latexmkrc, .nethackrc   # $HOME 直下に配置
├── .config/                                     # ~/.config 以下にリンク
│   ├── nvim/        # Neovim 設定 (init.lua + lua/)
│   ├── sheldon/     # zsh プラグインマネージャ
│   ├── tmux/        # tmux.conf
│   ├── wezterm/     # 環境別 (wsl2 / nucbox / windows) 設定あり
│   ├── polybar/, stylua/
│   └── systemd/     # ユーザユニット (obsidian.service など)
├── .claude/         # Claude Code の CLAUDE.md / hooks / commands / skills
│   ├── skills/          # 全マシン共通のスキル
│   └── skills_nucbox/   # そのマシンにだけ配るスキル (skills_<machine>/)
├── claude/          # ~/.claude/settings.json へ jq でマージする共有設定
├── bin/             # 補助スクリプト (.zshenv が PATH に追加する)
├── zsh/             # alias.zsh など .zshrc から読み込まれる断片
├── etc/init/        # 新マシン初期セットアップスクリプト群
├── doc/             # 設定の参考資料
├── packages.txt     # apt で永続的にインストールするパッケージ一覧
├── packages-ignore.txt  # packages-diff で無視するパッケージ
├── Brewfile         # macOS: brew bundle でインストールするパッケージ一覧
└── Makefile
```

## セットアップ

新マシンでの初回。先に Nix を入れる（sudo のパスワードを聞かれる。手順は [nixos.org/download](https://nixos.org/download/)）:

```sh
# macOS
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
# Linux
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --daemon
```

新しいシェルを開いてから:

```sh
git clone https://github.com/nitomoki/dotfiles.git ~/dotfiles
cd ~/dotfiles
make packages-install   # Linux: packages.txt を apt / macOS: Brewfile を brew bundle（Homebrew が要る）
make switch             # home-manager で配布とパッケージを反映
make init               # etc/init/*.sh を順次実行 (任意)
make setup-macos-defaults  # macOS のみ。Ctrl+Space を tmux の prefix に使えるよう macOS のショートカットを外す
```

`make deploy` で配っていたマシンを移すときは、初回だけ `make switch HM_BACKUP=pre-nix` とする。既存のリンクのうち中身が違うものが `<名前>.pre-nix` に退避される（退避先が既にあると home-manager は止まる）。

### home-manager での配布

- 設定ファイルは `~/dotfiles` の実ファイルを指すリンクとして配る（`mkOutOfStoreSymlink`）。ファイルを編集すれば `switch` しなくても効く。switch が要るのはファイルを足した・消したとき、パッケージを変えたとき。
- 配るファイルの一覧は git に入っているものから取る。新しいファイルは `git add` してから `make switch` する。
- 配る範囲は `make deploy` と同じ。加えて、`.config/wezterm/wezterm_<machine>.lua` を `wezterm_env.lua` としてリンクし、macOS では wezterm の terminfo も登録する（以前の `make setup-wezterm-*` に相当）。
- マシンの判定は `make deploy` と同じ `MACHINE`（`mac` / `nucbox` / `wsl2`）で、flake の `homeConfigurations.<MACHINE>` を使う。
- `make switch` は worktree からは実行できない。リンクは常に `~/dotfiles` を指すので、worktree にしか無いファイルへのリンクが切れるため。worktree では `make nix-build` でビルドだけ確かめる。
- `.zshenv` が `nix-daemon.sh` を読み、`~/.nix-profile/bin` を brew / apt より先に PATH へ入れる。`~/.local/bin` はさらに先なので、そこにある私用フォークの mosh などが優先される。

### Nix の無いマシン

`make deploy` で従来どおりシンボリックリンクを張れる。home-manager が配布を管理しているマシンでは、張り合いにならないよう `make deploy` は何もせず止まる。

Makefile は `uname -s` で OS を判定する。macOS では次のように振る舞いが変わる（`make switch` も同じ）。

- `.config/polybar` と systemd ユニットは配らない。
- `MACHINE` は hostname に関係なく `mac` になる (`.claude/skills_mac/` が配布対象)。
- `make init` は OS に依存しない `etc/init/4_config.sh` と `etc/init/markdown-reader.sh` だけを実行する。gnome、apt、ufw、Linux 版のバイナリを入れるスクリプトは対象外。
- `make packages-diff` は `brew bundle check` と `brew bundle cleanup` の dry-run を表示する。

### WezTerm

`make switch` を使うマシンでは、環境別の設定（`wezterm_env.lua`）も配られる。Nix の無いマシンと Windows では環境別の設定を 1 つ選択する:

```sh
make setup-wezterm-wsl2        # WSL2 (Linux 側)
make setup-wezterm-nucbox      # Nucbox (Linux)
make setup-wezterm-mac         # macOS
make setup-wezterm-windows WEZTERM_DIR=/mnt/c/Users/<user>/.config/wezterm
```

`wezterm_env.lua` は `.gitignore` 済み。

## WezTerm から画像を渡す (Alt+i)

手元 (Windows / macOS) のクリップボードにある画像を保存し、その絶対パスを端末にタイプする。Nucbox の Claude Code のようにリモートで動くプログラムへ画像を渡すための経路。

| キー | 置き先 | タイプされるパス |
| --- | --- | --- |
| `Alt+i` | `$WEZTERM_IMGPASTE_HOST` (既定 `nucbox`) | リモートの絶対パス |
| `Alt+Shift+i` | 手元 (WSL2 / Mac) | 手元の絶対パス |

リモートのプロセスは手元のクリップボードを見られない（読めるのは自分が動いているマシンのクリップボードだけ）ので、`Ctrl+V` での画像貼り付けは原理的に成立しない。そこで画像そのものは端末を通さず `ssh` で送り、mosh / et のセッションには「保存先パスの文字列」だけを流す。

- 実体は `bin/wezterm-imgpaste`（Windows では WSL2 上で `powershell.exe`、macOS では `osascript` でクリップボードを読む）と、キーバインド定義の `.config/wezterm/wezterm_windows.lua` / `wezterm_mac.lua`。
- 保存先は両側とも `${XDG_CACHE_HOME:-~/.cache}/wezterm-imgpaste/` で、新しい 50 件だけ残して間引かれる。
- 置き先は自動判定しない。ペインの前面プロセス名からの推測は et / tmux 越しだと当てにならず、外すと存在しないパスを黙って打ち込むことになるため、キーで明示する。
- Explorer / Finder でコピーしたファイルも同じキーで送れる（1 つ目のみ、32 MiB まで）。
- キーバインドは Windows / macOS 環境のみ。環境別設定から共通の `keys` を潰さずに追加するため、`extra_keys` で渡し、`wezterm.lua` 側で結合している。

## tmux セッションの切り替え (prefix + Space)

ゲーム / 仕事 / HTB / 小説 のようにテーマごとに tmux セッションを分け、それを横断するための仕組み。

| キー | 動作 |
| --- | --- |
| `prefix + Space` / `prefix + C-Space` | fzf の popup でセッションを選択。一覧に無い名前を入力して Enter すると、その名前でセッションを新規作成して切り替える |
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

WezTerm の launch menu の「(tmux)」系エントリも固定セッションではなくこのピッカーを開く。`zsh -lc` は `.zshrc` を読まないため zsh 関数 `t` は使えず、`tmux-sessionizer` を直接起動している（PATH は `.zshenv` が通す）。

## Claude Code のスキル

スキルは 3 つに置き分ける。

| 置き場所 | git | 配布先 |
| --- | --- | --- |
| `.claude/skills/` | 追跡する | 全マシン |
| `.claude/skills_<machine>/` | 追跡する | そのマシンのみ |
| `~/.claude/skills/` へ直接置く | 管理外 | そのマシンのみ |

`<machine>` は `hostname` から決まる (`tomoki-NucBox-G10` なら `nucbox`、macOS なら
`mac`、それ以外は `wsl2`)。`make switch MACHINE=wsl2` で上書きできる。

真ん中は「そのマシンでしか使わないが、手順の記録は残したい」もの。スキルの説明文は
全セッションのコンテキストに載るため、使わないマシンに配ると無駄になるうえ、前提の
揃っていないマシンで誤って呼ばれる余地も残る。`moshi-update` (moshi-hook の更新手順)
が該当し、moshi を入れている NucBox にだけ配っている。

配布先を移したとき (全マシン共通 → マシン専用 など) に他マシンへ残る古いリンクは、
`make switch` (または `make deploy`) が `~/.claude/skills/` のリンク切れを掃除するので放置してよい。

## Makefile ターゲット

```
make help                # ヘルプを表示
make switch              # home-manager で配布とパッケージを反映
make nix-build           # home-manager の設定をビルドだけする（~ は触らない）
make nix-check           # 全マシンの設定を評価し、このマシンの分をビルドする
make nix-update          # flake.lock の nixpkgs / home-manager を更新
make deploy              # シンボリックリンクを作成（Nix の無いマシン用）
make test                # deploy で作成されるリンクを dry-run 表示
make init                # etc/init/*.sh を順次実行
make packages-install    # packages.txt を apt / Brewfile を brew bundle でインストール
make packages-diff       # インストール済みとパッケージ一覧の差分を表示
make setup-wezterm-*     # 環境別の wezterm 設定をリンク／コピー
```

`make nix-check` は Mac で走らせても Linux 用の設定（逆も同じ）を評価するので、片方のマシンで両方の OS の設定ミスを拾える。ビルドまでするのは手元の OS の分だけ。

`make deploy` は冪等で、既存リンクは `ln -sfnv` で張り直される。`.config/systemd/user/` だけは他アプリの管理ファイルが混ざる場所なので、Makefile の `SYSTEMD_USER_FILES` で個別管理しているユニット (例: `obsidian.service`) のみリンクされる。

`make switch` と `make deploy` はリンク配置に加えて `sheldon lock` も実行する。sheldon の lock ファイルには `zsh/*.zsh` を展開した結果のファイル一覧が焼き込まれており、lock が作り直されるのは `plugins.toml` が変わったときだけ。`zsh/` にファイルを新規追加しても `plugins.toml` は無変更なので、lock を再生成しない限り新しいファイルは永久に読み込まれない (`zsh/tmux.zsh` 追加時にこれで `tc` が壊れた)。

## パッケージ管理

- 共通の CLI ツール (neovim, tmux, ripgrep, gh, sheldon, tree-sitter など) は `nix/home.nix` の `home.packages` に書き、`make switch` で反映する。版は `flake.lock` で固定され、`make nix-update` で上げる。
- node と cpanm は Nix に入れず、apt / brew に残す。Nix の store は読み取り専用で、`npm -g` や cpanm が書き込めないため。
- `packages.txt` を編集 → `make packages-install` で反映。
- 追加で手動インストールしたものを把握するには `make packages-diff`。
  - `packages.txt にない手動インストール済` と `packages.txt にあるが未インストール` の差分を出す。
  - Ubuntu base / kernel など追跡したくないものは `packages-ignore.txt` に書く。
- apt source / `.deb` / snap が必要なもの (gh, tailscale, wezterm, obsidian, steam-launcher など) は `packages.txt` に載せていてもインストール経路が別なことがある。
- mosh は `make init` の `etc/init/mosh.sh` が、カスタム版 (nitomoki/mosh の Release のビルド済みバイナリ) を `~/.local` に入れる。入れられない環境では apt (Linux) / brew (Mac) の mosh にする。`.zshenv` が `~/.local/bin` を先に PATH へ入れるので、手元もリモートも `mosh` / `mosh-server` を名前で呼べばカスタム版になる。
- markdown-reader (私用フォーク nitomoki/markdown-reader) は `make init` の `etc/init/markdown-reader.sh` が、Release のビルド済みバイナリ (Linux x86_64 / macOS arm64) を `~/.local/bin` に入れる。再実行すると最新リリースに更新する。入れられない環境ではフォークを `cargo install` でビルドする。


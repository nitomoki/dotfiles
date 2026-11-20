SHELL := /bin/bash
# $(PWD) ではなく $(CURDIR) を使う。$(PWD) は呼び出し元シェルの環境変数なので
# `make -C <dir>` でディレクトリを移しても追従しない。
DOTFILES_DIR := $(CURDIR)

# home-manager のリンクは常に ~/dotfiles を指すので、worktree での switch は断る（switch 参照）。
# 判定は git-dir 比較。worktree では --absolute-git-dir が
# <本体>/.git/worktrees/<name> になり、--git-common-dir（<本体>/.git）と食い違う。
# git が無い / リポジトリ外なら GIT_DIR が空になるので、その場合は素通しする。
GIT_DIR        := $(shell git rev-parse --absolute-git-dir 2>/dev/null)
GIT_COMMON_DIR := $(shell git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
IN_WORKTREE    := $(if $(GIT_DIR),$(if $(filter $(GIT_DIR),$(GIT_COMMON_DIR)),,yes))

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
IS_MAC := yes
endif

# flake の homeConfigurations / darwinConfigurations の名前。~/.claude/CLAUDE.md の
# 規約に合わせ hostname で見分け、macOS は hostname に依らず mac とする。
# 自動判定を外したいときは make switch MACHINE=wsl2 のように上書きする。
MACHINE ?= $(if $(IS_MAC),mac,$(if $(filter tomoki-NucBox-G10,$(shell hostname)),nucbox,wsl2))

# パッケージ一覧（macOS の Homebrew は nix/darwin.nix の homebrew で管理する）
PACKAGES_FILE := packages.txt
# packages-diff から除外する Ubuntu base / kernel 系
PACKAGES_IGNORE_FILE := packages-ignore.txt

# Nix で扱えない OS 側の設定（root 権限でシステムを書き換えるもの）。
SETUP_SCRIPT := etc/setup-$(if $(IS_MAC),macos,linux).sh

# --- Nix / home-manager ---
# 初回は nix.conf がまだ無い（home-manager が作る）ので、flakes をここで有効にする。
# --extra-experimental-features では足りない。home-manager が中で呼ぶ nix に届かないため。
NIX := NIX_CONFIG='experimental-features = nix-command flakes' nix
# 初回の switch で、配布先に既にあるファイル（以前 ln -s で張ったリンクなど）を
# <名前>.<HM_BACKUP> に退避させるときに指定する（例: make switch HM_BACKUP=pre-nix）。
# 退避先が既にあると home-manager は止まる。
HM_BACKUP ?=
HM_FLAGS := $(if $(HM_BACKUP),-b $(HM_BACKUP))
# Mac は nix-darwin（home-manager はその中で動く）。システムを書き換えるので root で動かす。
# sudo は環境変数と PATH を引き継がないので、nix は絶対パスで呼び NIX_CONFIG は env で渡す。
# -H は HOME を root にするため（他人の HOME だと nix が警告し、root のキャッシュを ~ に作る）。
DARWIN_REBUILD := sudo -H env NIX_CONFIG='experimental-features = nix-command flakes' \
	$(shell command -v nix) run .\#darwin-rebuild --
# Homebrew の一覧は nix/darwin.nix から生成する（brew bundle の --file=- は標準入力から読む）。
DARWIN_BREWFILE := $(NIX) eval --raw .\#darwinConfigurations.mac.config.homebrew.brewfile
ifdef IS_MAC
NIX_BUILD_TARGET := .\#darwinConfigurations.mac.system
else
NIX_BUILD_TARGET := .\#homeConfigurations.$(MACHINE).activationPackage
endif

.PHONY: help switch nix-build nix-check nix-update setup markdown-reader packages-diff setup-wezterm-windows

help: ## ヘルプを表示
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2}'

switch: ## 配布とパッケージを反映（Mac: nix-darwin + Homebrew / Linux: home-manager）
# home-manager のリンクは worktree ではなく常に ~/dotfiles を指すが、配るファイルの一覧は
# 実行した場所から取る。worktree で switch すると、まだ ~/dotfiles に無いファイルへの
# リンク切れが配られるので断る。worktree では nix-build で確認する。
	@if [ "$(IN_WORKTREE)" = yes ]; then echo "worktree では switch しない（make nix-build で確認する）"; exit 1; fi
ifdef IS_MAC
	$(DARWIN_REBUILD) switch --flake .#mac
else
	$(NIX) run .#home-manager -- switch --flake .#$(MACHINE) $(HM_FLAGS)
endif

nix-build: ## 設定をビルドだけする（~ も /etc も触らない。結果は ./result）
	$(NIX) build $(NIX_BUILD_TARGET)

nix-check: ## 全マシンの設定を評価し、このマシンの分をビルドする
	$(NIX) flake check --all-systems

nix-update: ## flake.lock の nixpkgs / home-manager を更新
	$(NIX) flake update

setup: ## OS 側の設定を反映（Nix で扱えないもの。Linux: apt・ufw・chsh / macOS: ショートカット・chsh）
	@bash $(SETUP_SCRIPT)

markdown-reader: ## 私用フォークの markdown-reader を ~/.local/bin に入れる・更新する
	@bash etc/markdown-reader.sh

packages-diff: ## インストール済みと一覧の差分を表示（Linux: apt-mark vs packages.txt / macOS: brew vs nix/darwin.nix）
ifdef IS_MAC
	@echo "[ nix/darwin.nix にあるが未インストール ]"
	@$(DARWIN_BREWFILE) | brew bundle check --verbose --no-upgrade --file=- || true
	@echo ""
	@echo "[ nix/darwin.nix にないインストール済（brew bundle cleanup の dry-run） ]"
	@$(DARWIN_BREWFILE) | brew bundle cleanup --file=- || true
else
	@comm -23 <(apt-mark showmanual | sort) \
		<(cat $(PACKAGES_FILE) $(PACKAGES_IGNORE_FILE) | grep -vE '^\s*(#|$$)' | sort -u) \
		| sed 's/^/  + /' \
		| awk 'BEGIN{print "[ packages.txt にない手動インストール済 ]"} {print}'
	@echo ""
	@comm -13 <(apt-mark showmanual | sort) \
		<(grep -vE '^\s*(#|$$)' $(PACKAGES_FILE) | sort) \
		| sed 's/^/  - /' \
		| awk 'BEGIN{print "[ packages.txt にあるが未インストール ]"} {print}'
endif

setup-wezterm-windows: ## Windows 用の wezterm 設定をコピー（WSL2 から実行: make setup-wezterm-windows WEZTERM_DIR=...)
	@if [ -z "$(WEZTERM_DIR)" ]; then \
		echo "Usage: make setup-wezterm-windows WEZTERM_DIR=/mnt/c/Users/<user>/.config/wezterm"; \
		exit 1; \
	fi
	@mkdir -pv $(WEZTERM_DIR)
	@cp -v $(DOTFILES_DIR)/.config/wezterm/wezterm.lua $(WEZTERM_DIR)/wezterm.lua
	@cp -v $(DOTFILES_DIR)/.config/wezterm/wezterm_windows.lua $(WEZTERM_DIR)/wezterm_env.lua

SHELL := /bin/bash
# $(PWD) ではなく $(CURDIR) を使う。$(PWD) は呼び出し元シェルの環境変数なので
# `make -C <dir>` でディレクトリを移しても追従せず、worktree ガードの配布元と
# .deploy-test の位置が本体側にずれる（実際に踏んだ）。
DOTFILES_DIR := $(CURDIR)

# --- worktree 内での deploy ガード ---
# dotfiles が配るのは symlink なので、worktree の中で `make deploy` を走らせると
# ~/.claude/CLAUDE.md や ~/.zshrc が worktree 内を指してしまい、worktree を消した
# 瞬間に全部リンク切れになる。拒否はせず、HOME を worktree 内のテスト用
# ディレクトリへ振り替えて「配布結果は確認できるが本物は壊さない」状態にする。
# Makefile のパスはすべて $(HOME) 経由なので、これだけで成立する。
#
# 判定は git-dir 比較。worktree では --absolute-git-dir が
# <本体>/.git/worktrees/<name> になり、--git-common-dir（<本体>/.git）と食い違う。
# git が無い / リポジトリ外なら GIT_DIR が空になるので、その場合は素通しする。
GIT_DIR        := $(shell git rev-parse --absolute-git-dir 2>/dev/null)
GIT_COMMON_DIR := $(shell git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
IN_WORKTREE    := $(if $(GIT_DIR),$(if $(filter $(GIT_DIR),$(GIT_COMMON_DIR)),,yes))

ifeq ($(IN_WORKTREE),yes)
ifndef ALLOW_WORKTREE_DEPLOY
# override はコマンドラインの HOME= 指定に負けないようにするため。
override HOME := $(DOTFILES_DIR)/.deploy-test
# sheldon lock はテスト HOME に大量に clone する（設定は実 HOME から読むのに
# データはテスト HOME へ書くため。実測 87MB）ので、このモードでは走らせない。
SKIP_SHELDON := yes
endif
endif

# --- シンボリックリンク対象 ---
# ホームディレクトリ直下に配置するドットファイル
HOME_DOTFILES := .gitignore .latexmkrc .nethackrc .zshrc

# .config 以下のディレクトリ（中身を直下までリンク）
# .config/systemd は user/ 配下に他アプリの管理ファイルが混ざるため、
# 個別ファイル単位でリンクする SYSTEMD_USER_FILES で扱う。
CONFIG_DIRS := $(filter-out .config/systemd, $(wildcard .config/??*))

# 個別管理する systemd --user ユニット／enable リンク
SYSTEMD_USER_FILES := \
	.config/systemd/user/obsidian.service \
	.config/systemd/user/graphical-session.target.wants/obsidian.service

# .claude 配下（Claude Code 設定）
# ディレクトリは symlink せず、.config と同じく中身を1ファイルずつリンクする。
# ~/.claude/commands のように Claude Code 側が実ディレクトリを作っている場合、
# ディレクトリを ln -sfn すると ~/.claude/commands/commands という入れ子 symlink に
# なり、同じコマンド/スキルが2パスから見えて二重に列挙されるため。
# ただし skills だけは 1スキル = 1ディレクトリ（SKILL.md 以外に references/ や
# scripts/ を持ちうる）なので、例外的にディレクトリ単位でリンクする。ファイル単位
# にするとスキルにファイルを足すたび deploy が要る。入れ子は link_dir で防ぐ。
#
# .claude/skills_<machine>/ はそのマシンでだけ使うスキル。全マシン共通の
# .claude/skills/ とは分け、deploy 時に MACHINE 一致分だけ ~/.claude/skills/ へ配る。
# 「git で残したいが他マシンには配りたくない」ものをここに置く（スキルの説明文は
# 全セッションのコンテキストに載るため、使わないマシンに配ると無駄になる）。
CLAUDE_SKILL_ENV_DIRS := $(patsubst %/,%,$(wildcard .claude/skills_*/))
CLAUDE_DIRS  := $(filter-out $(CLAUDE_SKILL_ENV_DIRS), $(patsubst %/,%,$(wildcard .claude/*/)))
CLAUDE_FILES := $(filter-out $(CLAUDE_DIRS) $(CLAUDE_SKILL_ENV_DIRS), $(wildcard .claude/*))
CLAUDE_SKILLS_DIR := $(HOME)/.claude/skills

# マシン判定。~/.claude/CLAUDE.md の規約に合わせ hostname で見分ける。
# 自動判定を外したいときは make deploy MACHINE=wsl2 のように上書きする。
MACHINE ?= $(if $(filter tomoki-NucBox-G10,$(shell hostname)),nucbox,wsl2)

# settings.json は .claude/ 直下に置くと dotfiles リポジトリ内で作業した際に
# Claude Code の「プロジェクト設定」として user 設定と二重ロードされ、hook
# （push 通知等）が2回発火する。これを避けるため配布元は claude/ 配下に置く。
# さらに ~/.claude/settings.json は symlink にせず、deploy 時に jq で共有設定
# （この settings.dotfiles.json）をローカル実ファイルへマージする。CLAUDE_LOCAL_KEYS
# のキーはローカル側にのみ持ち、マージ時に保全する
# （/model の書き込み先は ~/.claude/settings.json なので、そこを実ファイルに
# して dotfiles を汚さず・上書きもされずに保持できる）。
CLAUDE_SETTINGS_SRC := claude/settings.dotfiles.json

# マージ時にローカル側の値を保全するキー。model / effortLevel は各 PC 固有、
# agentPushNotifEnabled は /config でセッション内から切り替えるもので、いずれも
# 配布物では持たない。ここに挙げ忘れたキーは deploy のたびに黙って消えるので注意。
CLAUDE_LOCAL_KEYS := model, effortLevel, agentPushNotifEnabled

# deploy から除外するファイル（環境別設定は setup-wezterm-* で配置する）
WEZTERM_ENV_FILES := %wezterm_wsl2.lua %wezterm_nucbox.lua %wezterm_windows.lua

# パッケージ一覧
PACKAGES_FILE := packages.txt
# packages-diff から除外する Ubuntu base / kernel 系
PACKAGES_IGNORE_FILE := packages-ignore.txt

# --- コマンド ---
LINK := ln -sfnv
MKDIR := mkdir -pv

# ディレクトリを symlink するときの入れ子防止。リンク先に実ディレクトリが在ると
# ln -sfn はその中にリンクを作ってしまい（~/.claude/skills/x/x）、同じスキルが
# 2パスから見えて二重に列挙される。実体がある場合は上書きせず警告に留める。
# 使い方: $(call link_dir,<配布元>,<リンク先>)
define link_dir
if [ -e "$(2)" ] && [ ! -L "$(2)" ]; then echo "  [warn] $(2) に実体があるためスキップ（退避してから再実行）"; else $(LINK) "$(1)" "$(2)"; fi;
endef

.PHONY: deploy test init packages-install packages-diff setup-wezterm-wsl2 setup-wezterm-nucbox setup-wezterm-windows help

help: ## ヘルプを表示
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2}'

deploy: ## dotfiles のシンボリックリンクを作成
	@[ -z "$(SKIP_SHELDON)" ] || echo "  [worktree] HOME=$(HOME) へ配ります（本物の ~ は触りません / 解除は ALLOW_WORKTREE_DEPLOY=1）"
	@$(MKDIR) $(HOME)/.config
	@$(foreach f, $(HOME_DOTFILES), \
		$(LINK) $(DOTFILES_DIR)/$(f) $(HOME)/$(f);)
	@$(foreach d, $(CONFIG_DIRS), \
		$(MKDIR) $(HOME)/$(d); \
		$(foreach f, $(filter-out $(WEZTERM_ENV_FILES), $(wildcard $(d)/*)), \
			$(LINK) $(DOTFILES_DIR)/$(f) $(HOME)/$(f);))
	@$(foreach f, $(SYSTEMD_USER_FILES), \
		$(MKDIR) $(HOME)/$(dir $(f)); \
		$(LINK) $(DOTFILES_DIR)/$(f) $(HOME)/$(f);)
	@$(MKDIR) $(HOME)/.claude
	@$(foreach f, $(CLAUDE_FILES), \
		$(LINK) $(DOTFILES_DIR)/$(f) $(HOME)/$(f);)
	@$(foreach d, $(CLAUDE_DIRS), \
		if [ -L $(HOME)/$(d) ]; then rm -f $(HOME)/$(d); fi; \
		if [ -L $(HOME)/$(d)/$(notdir $(d)) ]; then rm -f $(HOME)/$(d)/$(notdir $(d)); fi; \
		$(MKDIR) $(HOME)/$(d); \
		$(foreach f, $(filter-out %/.gitkeep, $(wildcard $(d)/*)), \
			$(if $(wildcard $(f)/.), \
				$(call link_dir,$(DOTFILES_DIR)/$(f),$(HOME)/$(f)), \
				$(LINK) $(DOTFILES_DIR)/$(f) $(HOME)/$(f);)))
	@echo "  skills MACHINE=$(MACHINE) (.claude/skills_$(MACHINE)/) -> $(CLAUDE_SKILLS_DIR)"
	@$(MKDIR) $(CLAUDE_SKILLS_DIR)
	@find $(CLAUDE_SKILLS_DIR) -maxdepth 1 -xtype l -printf '  unlink %p (リンク切れ)\n' -delete
	@$(foreach f, $(wildcard .claude/skills_$(MACHINE)/*), \
		$(call link_dir,$(DOTFILES_DIR)/$(f),$(CLAUDE_SKILLS_DIR)/$(notdir $(f))))
	@echo "  merge  $(CLAUDE_SETTINGS_SRC) -> $(HOME)/.claude/settings.json ($(CLAUDE_LOCAL_KEYS) は保全)"
	@if [ -L $(HOME)/.claude/settings.json ]; then rm -f $(HOME)/.claude/settings.json; fi
	@if [ ! -f $(HOME)/.claude/settings.json ]; then \
		cp $(DOTFILES_DIR)/$(CLAUDE_SETTINGS_SRC) $(HOME)/.claude/settings.json; \
	elif command -v jq >/dev/null 2>&1; then \
		jq -s '.[1] + (.[0] | {$(CLAUDE_LOCAL_KEYS)} | with_entries(select(.value != null)))' \
			$(HOME)/.claude/settings.json $(DOTFILES_DIR)/$(CLAUDE_SETTINGS_SRC) \
			> $(HOME)/.claude/settings.json.tmp \
			&& mv $(HOME)/.claude/settings.json.tmp $(HOME)/.claude/settings.json; \
	else \
		echo "  [warn] jq が無いため settings.json のマージをスキップ（既存を保持）"; \
	fi
# sheldon の lock には zsh/*.zsh を展開した「ファイル一覧」が焼き込まれる。
# sheldon が lock を作り直すのは plugins.toml が変わったときだけなので、zsh/ に
# ファイルを新規追加しても plugins.toml は無変更 → 新しいファイルが永久に読まれ
# ない。実際 zsh/tmux.zsh 追加時に tc/t が未定義のまま（tc が /usr/sbin/tc に
# 解決される）という事故が起きたため、deploy のたびに lock を作り直す。
# 既存プラグインの更新はしたくないので --update は付けない。
	@if [ -n "$(SKIP_SHELDON)" ]; then \
		echo "  skip   sheldon lock (worktree テストモード)"; \
	elif command -v sheldon >/dev/null 2>&1; then \
		echo "  lock   sheldon (zsh/*.zsh の一覧を再生成)"; \
		out=$$(sheldon lock 2>&1) \
			|| echo "  [warn] sheldon lock に失敗（既存の lock を保持）: $$out"; \
	else \
		echo "  [warn] sheldon が無いため lock をスキップ"; \
	fi

test: ## deploy で作成されるリンクを確認（実行はしない）
	@[ -z "$(SKIP_SHELDON)" ] || echo "[worktree] HOME=$(HOME)（本物の ~ には配りません / 解除は ALLOW_WORKTREE_DEPLOY=1）"
	@echo "=== Home dotfiles ==="
	@$(foreach f, $(HOME_DOTFILES), \
		echo "  $(DOTFILES_DIR)/$(f) -> $(HOME)/$(f)";)
	@echo ""
	@echo "=== .config ==="
	@$(foreach d, $(CONFIG_DIRS), \
		$(foreach f, $(filter-out $(WEZTERM_ENV_FILES), $(wildcard $(d)/*)), \
			echo "  $(DOTFILES_DIR)/$(f) -> $(HOME)/$(f)";))
	@echo ""
	@echo "=== systemd --user ==="
	@$(foreach f, $(SYSTEMD_USER_FILES), \
		echo "  $(DOTFILES_DIR)/$(f) -> $(HOME)/$(f)";)
	@echo ""
	@echo "=== .claude ==="
	@$(foreach f, $(CLAUDE_FILES), \
		echo "  $(DOTFILES_DIR)/$(f) -> $(HOME)/$(f)";)
	@$(foreach d, $(CLAUDE_DIRS), \
		$(foreach f, $(filter-out %/.gitkeep, $(wildcard $(d)/*)), \
			echo "  $(DOTFILES_DIR)/$(f) -> $(HOME)/$(f)";))
	@$(foreach f, $(wildcard .claude/skills_$(MACHINE)/*), \
		echo "  $(DOTFILES_DIR)/$(f) -> $(CLAUDE_SKILLS_DIR)/$(notdir $(f))  [MACHINE=$(MACHINE)]";)
	@echo "  merge $(DOTFILES_DIR)/$(CLAUDE_SETTINGS_SRC) -> $(HOME)/.claude/settings.json (jq)"

init: ## 初期セットアップスクリプトを実行
	@$(foreach val, $(sort $(wildcard etc/init/*.sh)), \
		echo "--- $(val) ---"; bash $(val);)

packages-install: ## packages.txt のパッケージを apt でインストール
	@bash etc/init/1_install.sh

packages-diff: ## apt-mark showmanual と packages.txt の差分を表示（packages-ignore.txt は除外）
	@comm -23 <(apt-mark showmanual | sort) \
		<(cat $(PACKAGES_FILE) $(PACKAGES_IGNORE_FILE) | grep -vE '^\s*(#|$$)' | sort -u) \
		| sed 's/^/  + /' \
		| awk 'BEGIN{print "[ packages.txt にない手動インストール済 ]"} {print}'
	@echo ""
	@comm -13 <(apt-mark showmanual | sort) \
		<(grep -vE '^\s*(#|$$)' $(PACKAGES_FILE) | sort) \
		| sed 's/^/  - /' \
		| awk 'BEGIN{print "[ packages.txt にあるが未インストール ]"} {print}'

setup-wezterm-wsl2: ## WSL2 用の wezterm 環境設定をリンク
	@$(MKDIR) $(HOME)/.config/wezterm
	@$(LINK) $(DOTFILES_DIR)/.config/wezterm/wezterm_wsl2.lua \
		$(HOME)/.config/wezterm/wezterm_env.lua

setup-wezterm-nucbox: ## Nucbox 用の wezterm 環境設定をリンク
	@$(MKDIR) $(HOME)/.config/wezterm
	@$(LINK) $(DOTFILES_DIR)/.config/wezterm/wezterm_nucbox.lua \
		$(HOME)/.config/wezterm/wezterm_env.lua

setup-wezterm-windows: ## Windows 用の wezterm 設定をコピー（WSL2 から実行: make setup-wezterm-windows WEZTERM_DIR=...)
	@if [ -z "$(WEZTERM_DIR)" ]; then \
		echo "Usage: make setup-wezterm-windows WEZTERM_DIR=/mnt/c/Users/<user>/.config/wezterm"; \
		exit 1; \
	fi
	@$(MKDIR) $(WEZTERM_DIR)
	@cp -v $(DOTFILES_DIR)/.config/wezterm/wezterm.lua $(WEZTERM_DIR)/wezterm.lua
	@cp -v $(DOTFILES_DIR)/.config/wezterm/wezterm_windows.lua $(WEZTERM_DIR)/wezterm_env.lua

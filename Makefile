SHELL := /bin/bash
DOTFILES_DIR := $(PWD)

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

# .claude 直下のファイル（Claude Code 設定）
CLAUDE_FILES := $(wildcard .claude/*)

# settings.json は .claude/ 直下に置くと dotfiles リポジトリ内で作業した際に
# Claude Code の「プロジェクト設定」として user 設定と二重ロードされ、hook
# （push 通知等）が2回発火する。これを避けるため配布元は claude/ 配下に置き、
# ~/.claude/settings.json へは個別に symlink する。
CLAUDE_SETTINGS_SRC := claude/settings.json

# deploy から除外するファイル（環境別設定は setup-wezterm-* で配置する）
WEZTERM_ENV_FILES := %wezterm_wsl2.lua %wezterm_nucbox.lua %wezterm_windows.lua

# パッケージ一覧
PACKAGES_FILE := packages.txt
# packages-diff から除外する Ubuntu base / kernel 系
PACKAGES_IGNORE_FILE := packages-ignore.txt

# --- コマンド ---
LINK := ln -sfnv
MKDIR := mkdir -pv

.PHONY: deploy test init packages-install packages-diff setup-wezterm-wsl2 setup-wezterm-nucbox setup-wezterm-windows help

help: ## ヘルプを表示
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2}'

deploy: ## dotfiles のシンボリックリンクを作成
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
	@$(LINK) $(DOTFILES_DIR)/$(CLAUDE_SETTINGS_SRC) $(HOME)/.claude/settings.json

test: ## deploy で作成されるリンクを確認（実行はしない）
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
	@echo "  $(DOTFILES_DIR)/$(CLAUDE_SETTINGS_SRC) -> $(HOME)/.claude/settings.json"

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

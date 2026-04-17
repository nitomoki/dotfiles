DOTFILES_DIR := $(PWD)

# --- シンボリックリンク対象 ---
# ホームディレクトリ直下に配置するドットファイル
HOME_DOTFILES := .gitignore .latexmkrc .nethackrc .zshrc

# .config 以下のディレクトリ（中身を再帰的にリンク）
CONFIG_DIRS := $(wildcard .config/??*)

# .claude 直下のファイル（Claude Code 設定）
CLAUDE_FILES := $(wildcard .claude/*)

# deploy から除外するファイル（環境別設定は setup-wezterm-* で配置する）
WEZTERM_ENV_FILES := %wezterm_wsl2.lua %wezterm_nucbox.lua %wezterm_windows.lua

# --- コマンド ---
LINK := ln -sfnv
MKDIR := mkdir -pv

.PHONY: deploy test init setup-wezterm-wsl2 setup-wezterm-nucbox setup-wezterm-windows help

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
	@$(MKDIR) $(HOME)/.claude
	@$(foreach f, $(CLAUDE_FILES), \
		$(LINK) $(DOTFILES_DIR)/$(f) $(HOME)/$(f);)

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
	@echo "=== .claude ==="
	@$(foreach f, $(CLAUDE_FILES), \
		echo "  $(DOTFILES_DIR)/$(f) -> $(HOME)/$(f)";)

init: ## 初期セットアップスクリプトを実行
	@$(foreach val, $(sort $(wildcard etc/init/*.sh)), \
		echo "--- $(val) ---"; bash $(val);)

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

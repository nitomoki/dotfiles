DOTFILES_DIR := $(PWD)

# --- シンボリックリンク対象 ---
# ホームディレクトリ直下に配置するドットファイル
HOME_DOTFILES := .gitignore .latexmkrc .nethackrc .zpreztorc .zshrc

# .config 以下のディレクトリ（中身を再帰的にリンク）
CONFIG_DIRS := $(wildcard .config/??*)

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
		$(foreach f, $(filter-out %example.wsl2.lua %example.windows.lua %example.nucbox.lua, $(wildcard $(d)/*)), \
			$(LINK) $(DOTFILES_DIR)/$(f) $(HOME)/$(f);))

test: ## deploy で作成されるリンクを確認（実行はしない）
	@echo "=== Home dotfiles ==="
	@$(foreach f, $(HOME_DOTFILES), \
		echo "  $(DOTFILES_DIR)/$(f) -> $(HOME)/$(f)";)
	@echo ""
	@echo "=== .config ==="
	@$(foreach d, $(CONFIG_DIRS), \
		$(foreach f, $(filter-out %example.wsl2.lua %example.windows.lua %example.nucbox.lua, $(wildcard $(d)/*)), \
			echo "  $(DOTFILES_DIR)/$(f) -> $(HOME)/$(f)";))

init: ## 初期セットアップスクリプトを実行
	@$(foreach val, $(sort $(wildcard etc/init/*.sh)), \
		echo "--- $(val) ---"; bash $(val);)

setup-wezterm-wsl2: ## WSL2 用の wezterm_local.lua を配置
	@$(MKDIR) $(HOME)/.config/wezterm
	@if [ -f $(HOME)/.config/wezterm/wezterm_local.lua ]; then \
		echo "wezterm_local.lua already exists, skipping"; \
	else \
		cp -v $(DOTFILES_DIR)/.config/wezterm/wezterm_local.example.wsl2.lua \
			$(HOME)/.config/wezterm/wezterm_local.lua; \
	fi

setup-wezterm-nucbox: ## Nucbox 用の wezterm_local.lua を配置
	@$(MKDIR) $(HOME)/.config/wezterm
	@if [ -f $(HOME)/.config/wezterm/wezterm_local.lua ]; then \
		echo "wezterm_local.lua already exists, skipping"; \
	else \
		cp -v $(DOTFILES_DIR)/.config/wezterm/wezterm_local.example.nucbox.lua \
			$(HOME)/.config/wezterm/wezterm_local.lua; \
	fi

setup-wezterm-windows: ## Windows 用の wezterm_local.lua を配置（パスを指定: make setup-wezterm-windows WEZTERM_DIR=...)
	@if [ -z "$(WEZTERM_DIR)" ]; then \
		echo "Usage: make setup-wezterm-windows WEZTERM_DIR=/path/to/wezterm/config"; \
		exit 1; \
	fi
	@if [ -f $(WEZTERM_DIR)/wezterm_local.lua ]; then \
		echo "wezterm_local.lua already exists at $(WEZTERM_DIR), skipping"; \
	else \
		cp -v $(DOTFILES_DIR)/.config/wezterm/wezterm_local.example.windows.lua \
			$(WEZTERM_DIR)/wezterm_local.lua; \
	fi

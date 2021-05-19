DOTFILES_EXCLUDES := .git .gitmodules .travis.yml
DOTFILES_TARGET   := $(wildcard .??*) bin
DOTFILES_DIR      := $(PWD)
DOTFILES_FILES    := $(filter-out $(DOTFILES_EXCLUDES), $(DOTFILES_TARGET))
NVIM_CONFIG_FILES := .config/nvim

deploy: $(NVIM_CONFIG_FILES)
	@$(foreach val, $(DOTFILES_FILES), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)
	@ln -snfv $(DOTFILES_DIR)/$(NVIM_CONFIG_FILES)/dein.toml $(HOME)/$(NVIM_CONFIG_FILES)/dein.toml
	@ln -snfv $(DOTFILES_DIR)/$(NVIM_CONFIG_FILES)/dein_lazy.toml $(HOME)/$(NVIM_CONFIG_FILES)/dein_lazy.toml
	@ln -snfv $(DOTFILES_DIR)/$(NVIM_CONFIG_FILES)/lua $(HOME)/$(NVIM_CONFIG_FILES)/lua
	@ln -snfv $(DOTFILES_DIR)/$(NVIM_CONFIG_FILES)/plugin $(HOME)/$(NVIM_CONFIG_FILES)/plugin
	@ln -snfv $(DOTFILES_DIR)/$(NVIM_CONFIG_FILES)/init.vim $(HOME)/$(NVIM_CONFIG_FILES)/init.vim

init:
	@$(foreach val, $(wildcard $(PWD)/etc/init/*.sh), bash $(val);)
	@$(foreach val, $(wildcard $(PWD)/etc/init/zsh/*.sh), zsh $(val);)

deplua:
	rm -f $(HOME)/$(NVIM_CONFIG_FILES)/init.vim
	@ln -snfv $(DOTFILES_DIR)/$(NVIM_CONFIG_FILES)/init.lua $(HOME)/$(NVIM_CONFIG_FILES)/init.lua

$(NVIM_CONFIG_FILES):
	mkdir ~/.config
	mkdir ~/.config/nvim

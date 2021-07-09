DOTFILES_EXCLUDES := .git .gitmodules .travis.yml
DOTFILES_TARGET   := $(wildcard .??*) bin
DOTFILES_DIR      := $(PWD)
DOTFILES_FILES    := $(filter-out $(DOTFILES_EXCLUDES), $(DOTFILES_TARGET))
CONFIG_DIR := .config
NVIM_CONFIG_DIR := .config/nvim
NVIM_CONFIG_TARGET := $(notdir $(wildcard $(DOTFILES_DIR)/$(NVIM_CONFIG_DIR)/*))
NVIM_CONFIG_FILES := $(filter-out init.lua, $(NVIM_CONFIG_TARGET))
NVIM_CONFIG_FILES_LUA := $(filter-out init.vim, $(NVIM_CONFIG_TARGET))

deploy:
	mkdir -p $(HOME)/$(CONFIG_DIR)
	mkdir -p $(HOME)/$(NVIM_CONFIG_DIR)
	@$(foreach val, $(DOTFILES_FILES), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)
	@$(foreach val, $(NVIM_CONFIG_TARGET), ln -sfnv $(HOME)/dotfiles/$(NVIM_CONFIG_DIR)/$(val) $(HOME)/$(NVIM_CONFIG_DIR)/$(val);)
#	@$(foreach val, $(NVIM_CONFIG_FILES), ln -sfnv $(HOME)/dotfiles/$(NVIM_CONFIG_DIR)/$(val) $(HOME)/$(NVIM_CONFIG_DIR)/$(val);)
#	@ln -snfv $(DOTFILES_DIR)/$(NVIM_CONFIG_DIR)/init.lua $(HOME)/$(NVIM_CONFIG_DIR)/init.lua
#	rm -f $(HOME)/$(NVIM_CONFIG_DIR)/init.lua
#	@ln -snfv $(DOTFILES_DIR)/$(NVIM_CONFIG_DIR)/dein.toml $(HOME)/$(NVIM_CONFIG_DIR)/dein.toml
#	@ln -snfv $(DOTFILES_DIR)/$(NVIM_CONFIG_DIR)/dein_lazy.toml $(HOME)/$(NVIM_CONFIG_DIR)/dein_lazy.toml
#	@ln -snfv $(DOTFILES_DIR)/$(NVIM_CONFIG_DIR)/lua $(HOME)/$(NVIM_CONFIG_DIR)/lua
#	@ln -snfv $(DOTFILES_DIR)/$(NVIM_CONFIG_DIR)/plugin $(HOME)/$(NVIM_CONFIG_DIR)/plugin
#	@ln -snfv $(DOTFILES_DIR)/$(NVIM_CONFIG_DIR)/init.vim $(HOME)/$(NVIM_CONFIG_DIR)/init.vim

test:
	@$(foreach val, $(NVIM_CONFIG_FILES), echo $(val);)
	@$(foreach val, $(NVIM_CONFIG_FILES_LUA), echo $(val);)

init:
	@$(foreach val, $(wildcard $(PWD)/etc/init/*.sh), bash $(val);)
	@$(foreach val, $(wildcard $(PWD)/etc/init/zsh/*.sh), zsh $(val);)

deplua:
	@ln -snfv $(DOTFILES_DIR)/$(NVIM_CONFIG_DIR)/init.lua $(HOME)/$(NVIM_CONFIG_DIR)/init.lua
	rm -f $(HOME)/$(NVIM_CONFIG_DIR)/init.vim


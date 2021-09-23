DOTFILES_EXCLUDES := .git .gitmodules .travis.yml .config
DOTFILES_TARGET   := $(wildcard .??*) bin
DOTFILES_DIR      := $(PWD)
DOTFILES_FILES    := $(filter-out $(DOTFILES_EXCLUDES), $(DOTFILES_TARGET))
CONFIG_DIR := .config
CONFIG_DIR_TARGET :=$(wildcard $(CONFIG_DIR)/??*)

MAKE_DIR_COMMAND := mkdir -pv
MAKE_LINK_COMMAND := ln -sfnv

deploy:
	$(MAKE_DIR_COMMAND) $(HOME)/$(CONFIG_DIR)
	@$(foreach val, $(DOTFILES_FILES), $(MAKE_LINK_COMMAND) $(abspath $(val)) $(HOME)/$(val);)
	@$(foreach val, $(CONFIG_DIR_TARGET), $(MAKE_DIR_COMMAND) $(HOME)/$(val);)
	@$(foreach val, $(CONFIG_DIR_TARGET), $(foreach val2, $(wildcard $(val)/??*), $(MAKE_LINK_COMMAND) $(DOTFILES_DIR)/$(val2) $(HOME)/$(val2);))

test:
	@$(foreach val, $(DOTFILES_FILES), echo $(abspath $(val)) $(HOME)/$(val);)
	@$(foreach val, $(CONFIG_DIR_TARGET), $(foreach val2, $(wildcard $(val)/??*), echo $(DOTFILES_DIR)/$(val2) $(HOME)/$(val2);))

init:
	@$(foreach val, $(wildcard $(PWD)/etc/init/*.sh), bash $(val);)
	@$(foreach val, $(wildcard $(PWD)/etc/init/zsh/*.sh), zsh $(val);)



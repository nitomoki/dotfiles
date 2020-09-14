DOTFILES_EXCLUDES := .git .gitmodules .travis.yml
DOTFILES_TARGET   := $(wildcard .??*) bin
DOTFILES_DIR      := $(PWD)
DOTFILES_FILES    := $(filter-out $(DOTFILES_EXCLUDES), $(DOTFILES_TARGET))
NVIM_CONFIG_FILES := ~/.config/nvim

deploy: $(NVIM_CONFIG_FILES)
	@$(foreach val, $(DOTFILES_FILES), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)
	@ln -snfv $(PWD)/.config/nvim/dein.toml ~/.config/nvim/
	@ln -snfv $(PWD)/.config/nvim/dein_lazy.toml ~/.config/nvim/
	@ln -snfv $(PWD)/.config/nvim/init.vim ~/.config/nvim/

init:
	@$(foreach val, $(wildcard $(PWD)/etc/init/*.sh), bash $(val);)
	@$(foreach val, $(wildcard $(PWD)/etc/init/zsh/*.sh), zsh $(val);)

$(NVIM_CONFIG_FILES):
	mkdir ~/.config
	mkdir ~/.config/nvim

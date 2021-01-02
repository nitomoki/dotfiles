
zinit ice depth=1; zinit light romkatv/powerlevel10k
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

source $DOTFILES_DIR/zsh/.p10k.zsh


zinit light zdharma/fast-syntax-highlighting

zinit light zsh-users/zsh-autosuggestions
bindkey '^K' autosuggest-accept

zinit light paulirish/git-open

zinit ice as"program" from"gh-r" mv"bat* -> bat" pick"bat/bat"
zinit light sharkdp/bat

zinit light zdharma/history-search-multi-word



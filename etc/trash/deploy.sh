#!/bin/bash

THIS_DIR=$(cd $(dirname $0); pwd)
NVIM_CONF_DIR="~/.config/nvim"


echo "start deployment..."
for f in .??*; do
    [ "$f" = ".git" ] && continue
    [ "$f" = ".config" ] && continue
#    [ "$f" = ""] && continue

    ln -snfv ~/dotfiles/"$f" ~/
done


echo "start NVIM set up..."
ln -snfv ~/dotfiles/.config/nvim/dein.toml ~/.config/nvim/
ln -snfv ~/dotfiles/.config/nvim/dein_lazy.toml ~/.config/nvim/
ln -snfv ~/dotfiles/.config/nvim/init.vim ~/.config/nvim/

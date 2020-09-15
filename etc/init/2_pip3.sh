#!/bin/bash

packages_pip3=(
    msgpack
    neovim
    Send2Trash
    neovim-remote
    python-language-server
    pyls
    pyls-isort
    pyls-black
)

for package in "${packages_pip3[@]}"; do
    sudo pip3 install  $package
done

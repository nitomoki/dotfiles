#!/bin/bash

packages_pip3=(
    msgpack
    neovim
    Send2Trash
)

for package in "${packages_pip3[@]}"; do
    sudo pip3 install  $package
done

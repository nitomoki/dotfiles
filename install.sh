#!/bin/bash

softwares=(
    curl
    make
    cmake
    git
    zsh
    build-essential
    pkg-config
    clang
    ninja-build
    gettext
    libtool
    libtool-bin
    autoconf
    automake
    unzip
    python3-pip
    fontconfig
    ruby
    lua
    gem
    nodejs
    npm
    pip3
)


for software in "${softwares[@]}"; do
    sudo apt install $software || sudo apt upgrade $software
done

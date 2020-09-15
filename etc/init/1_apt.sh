#!/bin/bash

packages=(
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
    lua5.4
    gem
    nodejs
    npm
    cargo
    libclang-8-dev
    silversearcher-ag
    ccls
    latexmk
)

sudo apt update
for package in "${packages[@]}"; do
    sudo apt install -y $package || sudo apt update $package
done
sudo apt upgrade
sudo apt autoremove



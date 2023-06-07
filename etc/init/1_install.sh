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
    python3
    fontconfig
    ruby
    gem
    nodejs
    npm
    cargo
    silversearcher-ag
    latexmk
    nkf
    perl
    xclip
    vim
    cpanminus
    ripgrep
)

if [ "`uname -r |grep 'arch'`" ]; then
    sudo pacman -Syyu --noconfirm
    for package in "${packages[@]}"; do
        sudo pacman -Sy --noconfirm $package
    done
    sudo pacman -Syyu --noconfirm
elif [ "`cat /etc/os-release | grep 'Ubuntu'`" ]; then
    sudo apt update -y
    sudo apt install -y ${packages[@]}
    sudo apt upgrade -y
    sudo apt autoremove -y
fi



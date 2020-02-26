#!/bin/bash

# variables {{{
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
    clang-tools-8
)

softwares_pip3=(
    msgpack
    neovim
)
# }}}

# functions {{{
function install_neovim(){
    echo "neovim install start..."
    git clone https://github.com/neovim/neovim /$HOME/neovim
    cd /$HOME/neovim
    make CMAKE_BUILD_TYPE=Release 
    sudo make install 
    cd /$HOME 
    echo "done"
}

function install_nerdfonts(){
    echo "nerd-fonts install start..."
    git clone https://github.com/ryanoasis/nerd-fonts.git /$HOME/nerd-fonts 
    cd /$HOME/nerd-fonts 
    ./install.sh
    cd /$HOME 
    rm -rf nerd-fonts
    echo "done"
}

function install_apt-softwares(){
    echo "apt install start..."
    sudo apt update -y
    for software in "${softwares[@]}"; do
        sudo apt install -y $software || sudo apt update $software
    done
    echo "done"
}

function install_pip3-softwares(){
    echo "pip3 install start..."
    sudo pip3 update -y
    for software_pip3 in "${softwares_pip3[@]}"; do
        sudo pip3 install -y $software_pip3 || sudo pip3 update
    done
    echo "done"
}


# }}}


# installing
install_apt
install_pip3
install_neovim
install_nerdfonts

echo "clangd setting"
sudo update-altanatives --install /usr/bin/clangd clangd usr/bin/clangd-8 100



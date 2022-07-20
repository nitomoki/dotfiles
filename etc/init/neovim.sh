#!/bin/bash

sudo apt install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
git clone https://github.com/neovim/neovim /$HOME/neovim
cd /$HOME/neovim
make CMAKE_BUILD_TYPE=RelWithDebInfo 
sudo make install 
cd /$HOME 
# rm -rf /$HOME/neovim


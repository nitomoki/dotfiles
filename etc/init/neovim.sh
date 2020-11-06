#!/bin/bash

git clone https://github.com/neovim/neovim /$HOME/neovim
cd /$HOME/neovim
sudo make CMAKE_BUILD_TYPE=Release 
sudo make install 
cd /$HOME 
sudo rm -rf /$HOME/neovim


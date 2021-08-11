#!/bin/bash

cd ~
git clone https://github.com/sumneko/lua-language-server ~/.cache/nvim/lspconfig/sumneko_lua/lua-language-server
cd ~/.cache/nvim/lspconfig/sumneko_lua/lua-language-server
git submodule update --init --recursive
cd ./3rd/luamake
compile/install.sh
cd ../..
./3rd/luamake/luamake rebuild
cd ~

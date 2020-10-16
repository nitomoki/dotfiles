#!/bin/bash

sudo apt update -y
git clone https://github.com/latex-lsp/texlab /$HOME/texlab
cd /$HOME/texlab
sudo cargo build --release
cd /$HOME

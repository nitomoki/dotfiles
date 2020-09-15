#!/bin/bash

sudo apt update -y
git clone https://github.com/latex-lsp/texlab /$HOME/texlab
cd /$HOME/texlab
cargo build --release
cd /$HOME

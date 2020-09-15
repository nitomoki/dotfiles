#!/bin/bash

cd /$HOME/Downloads
curl -O https://github.com/yuru7/HackGen/releases/download/v2.1.1/HackGenNerd_v2.1.1.zip
unzip HackGenNerd_v2.1.1.zip
cd HackGenNerd_v2.1.1/
if [ ! -e {/$HOME/.fonts} ]; then
    mkdir /$HOME/.fonts
fi
cp *.ttf /$HOME/.fonts
cd /$HOME
sudo fc-cache -fv

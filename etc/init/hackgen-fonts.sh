#!/bin/bash

cd /$HOME
curl -O https://github.com/yuru7/HackGen/releases/download/v2.1.1/HackGenNerd_v2.1.1.zip
unzip HackGenNerd_v2.1.1.zip
if [ ! -e {/$HOME/.fonts} ]; then
    mkdir /$HOME/.fonts
fi
cp /$HOME/HackGenNerd_v2.1.1/*.ttf /$HOME/.fonts
cd /$HOME
sudo fc-cache -fv
sudo rm -rf /$HOME/HackGenNerd_v2.1.1

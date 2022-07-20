#!/bin/bash

(
VERSION="v2.6.3"
cd /$HOME
wget https://github.com/yuru7/HackGen/releases/download/$VERSION/HackGenNerd_$VERSION.zip
unzip HackGenNerd_$VERSION.zip
if [ ! -e /$HOME/.fonts ]; then
    mkdir /$HOME/.fonts
fi
cp /$HOME/HackGenNerd_$VERSION/*.ttf /$HOME/.fonts/
cd /$HOME
fc-cache -fv
sudo rm -rf /$HOME/HackGenNerd_$VERSION
sudo rm /$HOME/HackGenNerd_$VERSION.zip
)

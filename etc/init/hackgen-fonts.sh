#!/bin/bash

cd /$HOME
wget https://github.com/yuru7/HackGen/releases/download/v2.2.1/HackGenNerd_v2.2.1.zip
unzip HackGenNerd_v2.2.1.zip
if [ ! -e /$HOME/.fonts ]; then
    mkdir /$HOME/.fonts
fi
cp /$HOME/HackGenNerd_v2.2.1/*.ttf /$HOME/.fonts/
cd /$HOME
fc-cache -fv
sudo rm -rf /$HOME/HackGenNerd_v2.2.1
sudo rm /$HOME/HackGenNerd_v2.2.1.zip

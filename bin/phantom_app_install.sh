#!/bin/zsh


if [ -e /$HOME/Downloads ]; then
    mkdir /$HOME/Downloads/
fi

cd /$HOME/Downloads

wget https://s3.amazonaws.com/dl.3dsystems.com/binaries/support/downloads/KB+Files/Open+Haptics/openhaptics_3.4-0-developer-edition-amd64.tar.gz
wget https://s3.amazonaws.com/dl.3dsystems.com/binaries/Sensable/Linux/TouchDriver2019_2_15_Linux.tar.xz

tar -xvf openhaptics_3.4-0-developer-edition-amd64.tar.gz
tar -xvf TouchDriver2019_2_15_Linux.tar.xz

rm -f openhaptics_3.4-0-developer-edition-amd64.tar.gz
rm -f TouchDriver2019_2_15_Linux.tar.xz


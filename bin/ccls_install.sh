#!/bin/bash

sudo git clone --depth=1 --recursive https://github.com/MaskRay/ccls /usr/src/ccls
cd /usr/src/ccls
sudo wget -c http://releases.llvm.org/8.0.0/clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz
sudo tar xf clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz
sudo cmake -H. \
    -BRelease \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=$PWD/clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04
sudo cmake --build Release --target install
cd ~/

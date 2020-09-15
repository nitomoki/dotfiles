#!/bin/bash

packages_pip=(
    neovim
)

curl -kL https://bootstrap.pypa.io/get-pip.py | python

for package in "${packages_pip[@]}"; do
    pip install  $package
done


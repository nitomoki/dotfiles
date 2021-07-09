#!/bin/bash

git config --get --global user.name | grep -q nitomoki
if [ "$?" -ne 0 ]; then
    git config --global user.email "nitomoki.2@gmail.com"
    git config --global user.name "nitomoki"
fi

grep -q zsh /etc/passwd
if [ "$?" -ne 0 ]; then
    chsh -s $(which zsh)
fi

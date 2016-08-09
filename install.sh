#!/bin/bash

cd ~
git clone https://github.com/wass80/dotfiles

find dotfiles -regex ".*\/\..*" -prune ! -name ".git" -exec ln -s {} \;


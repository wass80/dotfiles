#!/bin/bash

cd ~
git clone https://github.com/wass80/dotfiles

find . -regex ".\\+" -exec ln -s {} \;

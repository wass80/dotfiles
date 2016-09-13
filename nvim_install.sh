#!/bin/bash -euvx

cd
mkdir -p .config/nvim
cd .config/nvim
ln -s ~/dotfiles/init.vim
ln -s ~/dotfiles/dein.toml

sudo apt-get install software-properties-common
sudo apt-get install python-software-properties
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install neovim
sudo apt-get install python-dev python-pip python3-dev python3-pip

pip3 install neovim

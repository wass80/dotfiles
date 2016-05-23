#!/bin/bash

cd ~
git clone https://github.com/wass80/dotfiles
cd dotfiles
ln -s .vimrc ~/.vimrc
ln -s .zshenv ~/.zshenv
ln -s .zshrc ~/.zshrc
ln -s .tmux.conf ~/.tmux.conf
ln -s .gitconfig ~/.gitconfig

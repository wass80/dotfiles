#!/bin/bash

cd ~
git clone https://github.com/wass80/dotfiles

ln -s dotfiles/.vimrc
ln -s dotfiles/.zshenv
ln -s dotfiles/.zshrc
ln -s dotfiles/.tmux.conf
ln -s dotfiles/.gitconfig

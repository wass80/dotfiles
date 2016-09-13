#!/bin/bash
wget http://ftp.gnu.org/gnu/gawk/gawk-4.1.4.tar.gz
tar xvf gawk-4.1.4.tar.gz
cd ./gawk-4.1.4
make
mkdir ~/.bin
cp ./gawk-4.4.1/gawk ~/.bin/awk


#!/bin/bash

# weaves
# This script is an example of how to run configure and build

cd smet
./autogen.sh
cd -

autoreconf --force --install
./configure --prefix=$HOME --with-qhomedir=$HOME/src/q --with-string-metrics --with-qtrdrhost=ubu --with-qtrdrport=15001
make

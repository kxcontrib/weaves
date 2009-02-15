#!/bin/bash

# weaves
# This script is an example of how to run configure and build

cd smet
eval `grep gnulib-tool INSTALL`
cd -

autoreconf --force --install
./configure --prefix=$HOME --htmldir=$HOME/share/Documents/sites/ubu/qsys --with-qhomedir=$HOME/src/q --with-string-metrics --with-qtrdrhost=ubu --with-qtrdrport=15001
make

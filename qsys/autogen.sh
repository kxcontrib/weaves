#!/bin/bash

# weaves
# This script is an example of how to run configure and build

# The build uses SVN to get externals: see INSTALL

cd smet
./autogen.sh
cd -

# Sometimes, I use git and that doesn't support externals.
if [ -d ../.git ]
then
 test -d lib || mkdir lib
 ( 
 cd lib 
 find . -maxdepth 1 -type l -exec rm -f {} \;
 cp -sr ../../../../kx/kdb+/l32/* .
 )
 
 test -d qdoc || ln -s ../qdoc .
 ( 
 cd qdoc/cfg
 ln -sf ~-/dev.doxy.in . 
 )
fi

cp lib2/Makefile.am lib

# autoreconf doesn't add missing files
aclocal && automake --add-missing --copy
autoreconf --force --install
./configure --prefix=$HOME --with-qhomedir=$HOME/src/q --with-string-metrics --with-qtrdrhost=$HOSTNAME --with-qtrdrport=15001 --disable-dependency-tracking
make

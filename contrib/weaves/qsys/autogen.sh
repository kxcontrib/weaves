#!/bin/bash

# weaves
# This script is an example of how to run configure and build
# it takes arguments on the command-line like this
#  autogen.sh smet=1
# It expects SHELL to be a BASH shell.

: ${QHOME:=$HOME/q}

for i in $*
do
    eval "$i"
done

if [ -n "$smet" -a $smet -ge 1 ]
then
    (   cd smet;
	$nodo $SHELL -e autogen.sh $*
    )
else
 unset smet
fi

# autoreconf doesn't add missing files
$nodo libtoolize --force

$nodo aclocal
$nodo automake --add-missing --copy
$nodo autoreconf --force --install

$nodo ./configure --prefix=$HOME --with-qhomedir=$QHOME \
 --with-string-metrics=${smet:+'no'} \
 --with-qtrdrhost=$HOSTNAME \
 --with-qtrdrport=15001 \
 --disable-dependency-tracking

$nodo make

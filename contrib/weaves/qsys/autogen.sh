#!/bin/bash

# weaves
# This script is an example of how to run configure and build
# it takes arguments on the command-line like this
#  autogen.sh smet=yes
# By default smet is no
#  autogen.sh smet=no nodo=echo
# Is a no-do method

# It expects SHELL to be a BASH shell.

for i in $*
do
    eval "$i"
done

# Make sure a QHOME has been set on the command-line or environment.
: ${QHOME:=$HOME/q}
test -d "$QHOME" || exit 1

# Make sure the string metrics have been set correctly.
: ${smet:="disable"}
if [ -n "${smet}" -a "$smet" = "enable" ]
then
    (   cd smet;
	$nodo $SHELL -e autogen.sh $*
    )
else
 smet="disable"
fi

# Not needed at this level
# $nodo libtoolize --force

# autoreconf doesn't add missing files

$nodo aclocal
$nodo automake --add-missing --copy
$nodo autoreconf --force --install

# We override the Q progdir because we only have Linux 32 bit
# We override the Q homedir because of a home directory layout quirk

$nodo ./configure --prefix=$HOME \
 --with-qhomedir=$QHOME \
 --with-qprogdir=$QHOME/l32 \
 --${smet}-string-metrics \
 --with-qtrdrhost=$HOSTNAME \
 --with-qtrdrport=15001 \
 --disable-dependency-tracking


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

if [ -n "$clean" -a "$clean" = "yes" ]
then
    set +e
    test -f Makefile && $nodo make distclean
    $nodo rm -rf m4 config lib
    $nodo find . -type d -name autom4te.cache -exec rm -rf {} \;
    $nodo find . -type f \( -name Makefile.in -o -name aclocal.m4 -o -name configure -o -name '*~' \) -delete
    exit 0
fi

# Make sure a QHOME has been set on the command-line or environment.
: ${QHOME:=$HOME/q}
test -d "$QHOME" || exit 1
: ${QOSTYPE:=l32}
test -d "$QHOME/$QOSTYPE" || exit 2
: ${QPROG:=q}
test -x "$QHOME/$QOSTYPE/$QPROG" || exit 3

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

test -d config || mkdir config

$nodo aclocal
$nodo automake --add-missing --copy
$nodo autoconf --force

# We override the Q progdir because we only have Linux 32 bit
# We override the Q homedir because of a home directory layout quirk

$nodo ./configure QHOME=$QHOME PATH=$PATH:$QHOME/${QOSTYPE} --prefix=$HOME \
 --${smet}-string-metrics \
 --with-qtrdrhost=$HOSTNAME \
 --with-qtrdrport=15001 \
 --disable-dependency-tracking

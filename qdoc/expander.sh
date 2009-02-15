#!/bin/bash

# weaves
# Expands the environment variables in the complete.doxo file
# Strangely, doxygen claims to expand env vars but doesn't 

test $# -ge 1 || exit -1

test -f $1 || exit -1

tfile=t.$$

(
echo "cat <<EOF"
cat $1 
echo ""
echo "EOF" ) > $tfile

$SHELL $tfile
rm -f $tfile


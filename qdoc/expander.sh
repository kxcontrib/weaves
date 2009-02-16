#!/bin/bash

# weaves
# Expands the environment variables in the complete.doxo file
# Strangely, doxygen claims to expand env vars but doesn't 

test $# -ge 1 || exit -1

test -f $1 || exit -1

tfile=t.$$
tfile1=t1.$$

(
echo "cat <<EOF"
cat $1 
echo ""
echo "EOF" ) > $tfile

$SHELL $tfile > $tfile1

cat $tfile1 | egrep '[A-Z]+_OUTPUT[ ]*=[ ]*' | awk -F= '{ print $2 }' | while read i
do
 test -d "$i" || mkdir -p "$i"
done

cat $tfile1

rm -f $tfile $tfile1


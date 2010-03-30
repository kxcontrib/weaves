#!/bin/sh

cat $* > t.$$

../qoxygen t.$$

rm -f t.$$


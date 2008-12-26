SUBDIRS = qoxygen

# SUBDIRS = qoxygen rtoq

bin_PROGRAMS=qtools
qtools_SOURCES=qtools.c qtools.1 xmalloc.c system.h aclocal.m4 getopt.c getopt1.c getopt.h

#  uncomment the following if qtools requires the math library
#qtools_LDADD=-lm

EXTRA_DIST=qtools.lsm.in qtools.spec.in qtools.texinfo

#  if you write a self-test script named `chk', uncomment the
#  following and add `chk' to the EXTRA_DIST list
#TESTS=chk

#  build and install the .info pages
info_TEXINFOS = qtools.texinfo
qtools_TEXINFOS = gpl.texinfo

#  install the man pages
man_MANS=qtools.1

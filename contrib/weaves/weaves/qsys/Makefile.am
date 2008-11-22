# weaves
# The $(subdirs) comes from the configure call - usually smet.

SUBDIRS = src $(subdirs)

noinst_PROGRAMS=qsys
qsys_SOURCES=qsys.c qsys.1 xmalloc.c system.h aclocal.m4 getopt.c getopt1.c getopt.h

#  uncomment the following if qsys requires the math library
#qsys_LDADD=-lm

EXTRA_DIST=qsys.lsm.in qsys.spec.in qsys.texinfo INSTALL

#  if you write a self-test script named `chk', uncomment the
#  following and add `chk' to the EXTRA_DIST list
#TESTS=chk

#  build and install the .info pages
info_TEXINFOS = qsys.texinfo
qsys_TEXINFOS = gpl.texinfo

#  install the man pages
man_MANS=qsys.1

clean-local:
	$(RM) make.log

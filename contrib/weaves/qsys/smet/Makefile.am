# weaves

## Regular expressions and string metrics for q/kdb

# The program is egexm - a dummy - used to dump the documentation

# The real target is a Position Independent Code object module
# built as a shared library with the -module switch

ACLOCAL_AMFLAGS = -I m4

CPPFLAGS = -Ilib

SUBDIRS = lib regex examples

noinst_PROGRAMS=egex
egex_SOURCES=egexm.c egex.1 xmalloc.c system.h aclocal.m4 getopt.c getopt1.c getopt.h

#  build and install the .info pages
info_TEXINFOS = egex.texinfo
egex_TEXINFOS = gpl.texinfo

#  install the man pages
man_MANS=egex.1

clean-local:
	$(SHELL) -c "rm -f cscope.*"
	rm -f make.log

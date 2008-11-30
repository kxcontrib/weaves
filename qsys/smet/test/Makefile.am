# weaves

## Regular expressions and string metrics for q/kdb

# These test programs check that the regular expression library is available.

ACLOCAL_AMFLAGS = -I m4

CPPFLAGS = -I $(top_builddir)/lib

LDADD = $(LTLIBINTL) $(top_builddir)/lib/libgnu.la

BUILT_SOURCES = README

README:
	$(TESTS_ENVIRONMENT) egex.sh

noinst_PROGRAMS = egex mygrep regexpr
egex_SOURCES = egexm.c egex.1 xmalloc.c getopt.c getopt1.c getopt.h

mygrep_SOURCES = mygrep.c 
regexpr_SOURCES = regexpr.c

TESTS = egex.sh mygrep.sh regexpr.sh
TESTS_ENVIRONMENT = $(SHELL) -x 

EXTRA_DIST = $(TESTS) README

#  build and install the .info pages
info_TEXINFOS = egex.texinfo

#  install the man pages
man_MANS=egex.1

clean-local:
	$(SHELL) -c "rm -f cscope.*"
	rm -f make.log

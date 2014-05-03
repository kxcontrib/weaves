AM_CFLAGS ?= -DNDEBUG
CPPFLAGS = -I${top_srcdir}/lib -DNO_PYTHON

ACLOCAL_AMFLAGS = -I m4

# The build of the test program doesn't work under Solaris.

# noinst_PROGRAMS = egext
# egext_SOURCES = egext.c
# egext_LDADD = c.o libqregex.la -lpthread -lm

BUILT_SOURCES = c.o

c.o:
	$(RM) $@
	$(LN_S) ${qprogdir}/c.o 

pkglib_LTLIBRARIES = libqregex.la
libqregex_la_LIBADD = $(LTLIBINTL) ${top_srcdir}/lib/libgnu.la
libqregex_la_SOURCES = egex0.c egex.c egex1.c Levenshtein.c kish.c smetrics.c version-etc-fsf.c

libqregex_la_FLAGS = -no-undefined -module

noinst_HEADERS = egex0.h  k.h  kish.h  Levenshtein1.h  Levenshtein.h  skel.h

#  if you write a self-test script named `chk', uncomment the
#  following and add `chk' to the EXTRA_DIST list

TESTS = egex.sh smet.sh egex1.sh
TESTS_ENVIRONMENT = $(SHELL) -x 

q_files_TEST = egex1.q egex.q smet.q egex2.q
q_files = regex.q.in

EXTRA_DIST = README $(TESTS) $(q_files_TEST) $(q_files)

CLEANFILES = regex.q

dist_pkgdata_DATA = regex.q

do_subst = sed -e 's,[@]pkgdatadir[@],$(pkgdatadir),g' \
	       -e 's,[@]sysconfdir[@],$(sysconfdir),g' \
	       -e 's,[@]pkglibdir[@],$(pkglibdir),g' \
	       -e 's,[@]qhomedir[@],$(qhomedir),g' \
	       -e 's,[@]qprogdir[@],$(qprogdir),g' \
	       -e 's,[@]qprog[@],$(qprog),g' \
               -e 's,[@]PERL[@],$(PERL),g' \
               -e 's,[@]PACKAGE[@],$(PACKAGE),g' \
               -e 's,[@]VERSION[@],$(VERSION),g'

install-data-local:
	true

#	cd $(qhomedir); $(RM) q.q; $(LN_S) $(pkgdatadir)/site.q q.q

%: %.in
	$(do_subst) < $(srcdir)/$< > $@
	chmod +x $@

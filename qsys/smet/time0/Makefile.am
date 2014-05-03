AM_CFLAGS ?= -DNDEBUG
CPPFLAGS = -I${top_srcdir}/lib -DNO_PYTHON

ACLOCAL_AMFLAGS = -I m4

# The build of the test program doesn't work under Solaris.

# noinst_PROGRAMS = egext
# egext_SOURCES = egext.c
# egext_LDADD = c.o libqtime.la -lpthread -lm

BUILT_SOURCES = c.o

c.o:
	$(RM) $@
	$(LN_S) ${qprogdir}/c.o 

pkglib_LTLIBRARIES = libqtime.la
libqtime_la_LIBADD = $(LTLIBINTL) ${top_srcdir}/lib/libgnu.la
libqtime_la_SOURCES = time0.c time01.c kish.c version-etc-fsf.c

libqtime_la_FLAGS = -no-undefined -module

noinst_PROGRAMS = time0t
time0t_LDADD = c.o libqtime.la $(libqtime_la_LIBADD) 
time0t_LDFLAGS = -static -lpthread 

noinst_HEADERS = time0.h k.h kish.h skel.h

#  if you write a self-test script named `chk', uncomment the
#  following and add `chk' to the EXTRA_DIST list

TESTS = time0.sh time01.sh
TESTS_ENVIRONMENT = $(SHELL) -x 

q_files_TEST = time01t.q time02t.q
q_files = time0.q.in

EXTRA_DIST = README $(TESTS) $(q_files_TEST) $(q_files)

CLEANFILES = time0.q

dist_pkgdata_DATA = time0.q

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


q_files = darwin8.0.q linux-gnu.q help.q log.q site.q sys.q trdr.q dbmaint.q

bin_SCRIPTS = Qp Qr Qs
sysconf_DATA = use-q q.rc
pkgdata_DATA = $(q_files)

CLEANFILES = $(bin_SCRIPTS) $(sysconf_DATA)

EXTRA_DIST = Qp.in Qr.in Qs.in use-q.in q.rc.in $(q_files)

do_subst = sed -e 's,[@]pkgdatadir[@],$(pkgdatadir),g' \
	       -e 's,[@]sysconfdir[@],$(sysconfdir),g' \
	       -e 's,[@]qhomedir[@],$(qhomedir),g' \
	       -e 's,[@]qprogdir[@],$(qprogdir),g' \
	       -e 's,[@]qtrdrhost[@],$(qtrdrhost),g' \
	       -e 's,[@]qtrdrport[@],$(qtrdrport),g' \
	       -e 's,[@]qprog[@],$(qprog),g' \
               -e 's,[@]PERL[@],$(PERL),g' \
               -e 's,[@]PACKAGE[@],$(PACKAGE),g' \
               -e 's,[@]VERSION[@],$(VERSION),g'

install-data-local:
	cd $(qhomedir); $(RM) q.q; $(LN_S) $(pkgdatadir)/site.q q.q

%: %.in
	$(do_subst) < $(srcdir)/$< > $@
	chmod +x $@

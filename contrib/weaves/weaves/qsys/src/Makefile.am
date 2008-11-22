CLEANFILES = $(dist_bin_SCRIPTS)

q_files = darwin8.0.q linux-gnu.q help.q log.q site.q sys.q trdr.q

dist_bin_SCRIPTS = Qp Qr Qs
dist_sysconf_DATA = use-q q.rc
dist_pkgdata_DATA = $(q_files)

EXTRA_DIST = Qp.in Qr.in Qs.in use-q.in q.rc $(q_files)

do_subst = sed -e 's,[@]pkgdatadir[@],$(pkgdatadir),g' \
	       -e 's,[@]sysconfdir[@],$(sysconfdir),g' \
	       -e 's,[@]qhomedir[@],$(qhomedir),g' \
	       -e 's,[@]qprogdir[@],$(qprogdir),g' \
	       -e 's,[@]qprog[@],$(qprog),g' \
               -e 's,[@]PERL[@],$(PERL),g' \
               -e 's,[@]PACKAGE[@],$(PACKAGE),g' \
               -e 's,[@]VERSION[@],$(VERSION),g'

install-data-local:
	cd $(qhomedir); $(RM) q.q; $(LN_S) $(pkgdatadir)/site.q q.q

%: %.in
	$(do_subst) < $(srcdir)/$< > $@
	chmod +x $@

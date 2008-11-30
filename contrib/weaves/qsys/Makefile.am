# weaves
# The $(subdirs) comes from the configure call - usually smet.

SUBDIRS = src $(subdirs)

EXTRA_DIST=qsys.lsm.in qsys.spec.in qsys.texinfo INSTALL aclocal.m4 qsys.1

#  build and install the .info pages
info_TEXINFOS = qsys.texinfo
qsys_TEXINFOS = gpl.texinfo

#  install the man pages
man_MANS=qsys.1

clean-local:
	$(RM) make.log

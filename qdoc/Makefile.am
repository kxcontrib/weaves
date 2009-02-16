## weaves
# 
# I've added some logic to use different DOXYGEN_CONFIG files
# Pre-process the configuration files
# and to perform post-processing of the documents.

# From the DOXYGEN_CONFIG generate a <name>.doxi
# There is a rule .doxo := .doxi that runs DOXYGEN on that .doxi
# Use the <name>.doxo as dependent to trigger any post-processing.

#  uncomment the following if qdoc requires the math library
#qdoc_LDADD=-lm

EXTRA_DIST=qdoc.lsm.in qdoc.spec.in qdoc.texinfo expander.sh index.cpp.sample aclocal.m4

#  if you write a self-test script named `chk', uncomment the
#  following and add `chk' to the EXTRA_DIST list
#TESTS=chk

#  build and install the .info pages
# info_TEXINFOS = qdoc.texinfo
# qdoc_TEXINFOS = gpl.texinfo

#  install the man pages
man_MANS=qdoc.1

SUBDIRS = cfg

DOXYGEN_CONFIG := cfg/dev.doxy

## Use this rule to run doxygen
# Adds versioning and runs doxygen

export

all: html

%.doxo: %.doxi
	rm -f $@
	$(SHELL) expander.sh $< > $@
	$(DOXYGEN) $@
	touch $@

html-local:
	$(MAKE) MAKEFLAGS=$(MAKEFLAGS) DOXYGEN_CONFIG=cfg/dev.doxy clean-local
	$(MAKE) MAKEFLAGS=$(MAKEFLAGS) DOXYGEN_CONFIG=cfg/dev.doxy complete.doxo

clean-local:
	$(SHELL) -c "$(RM) *.doxo *.doxi *.log"
	-rm -rf html

distclean-local: clean-local
	rm -Rf man
	rm -Rf latex
	rm -f .time-stamp*

complete.doxi: $(DOXYGEN_CONFIG)
	cat $+ | egrep -v '(^#)|(^$$)|(^[ ]+$$)' | $(SED) -e 's/GENERATE_MAN[ \t]*=[ \t]*NO/GENERATE_MAN           = NO/' \
           -e 's/GENERATE_HTML[ \t]*=[ \t]*NO/GENERATE_HTML          = YES/' \
           -e 's/GENERATE_LATEX[ \t]*=[ \t]*NO/GENERATE_LATEX         = NO/' \
           -e 's|@basepath@|$${top_srcdir}|' > $@


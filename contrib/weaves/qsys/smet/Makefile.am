# weaves

## Regular expressions and string metrics for q/kdb

# The test directory makes sure a regular expression library
# works

# The real target is a Position Independent Code object module
# built as a shared library with the -module switch in
# regex

ACLOCAL_AMFLAGS = -I m4

SUBDIRS = lib test regex time0 examples

#  build and install the .info pages
egex_TEXINFOS = gpl.texinfo
EXTRA_DIST = m4/gnulib-cache.m4

clean-local:
	$(SHELL) -c "rm -f cscope.*"
	rm -f make.log

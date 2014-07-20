INSTALL0 ?= /usr/local/lib/R/site-library

all:
	$(RM) $(wildcard q4r_?.?.tar.gz)
	R CMD check q4r --no-examples
	R CMD build q4r

install:
	R CMD INSTALL -l $(INSTALL0) q4r

am-install-local:
	cp tools/doxygen0/Setup/Release/doxygenf.msi dists
	cp tools/doxygen0/Setup/Release/setup.exe dists/doxygenf.exe

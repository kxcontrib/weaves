all:
	R CMD build q4r
	R CMD INSTALL q4r_0.1.tar.gz

am-install-local:
	cp tools/doxygen0/Setup/Release/doxygenf.msi dists
	cp tools/doxygen0/Setup/Release/setup.exe dists/doxygenf.exe

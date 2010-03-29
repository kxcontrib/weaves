all:
	R CMD build q4r
	R CMD INSTALL q4r_0.1.tar.gz

am-install-local:
	cp tools/qoxygen/Setup/Release/qoxygen.msi dists
	cp tools/qoxygen/Setup/Release/setup.exe dists/qoxygen_setup.exe

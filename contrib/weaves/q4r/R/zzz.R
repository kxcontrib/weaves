# Manual version
load.q <- function() {
  lib.loc = paste(.libPaths()[[1]], "q4r", "libs", "q4r.so", sep="/")
  dyn.load(lib.loc)
}

.First.lib <- function(lib, pkg) {
  # not called because this package has a namespace
}

.onLoad <- function(libname, pkgname) {
  # cat(paste(libname, pkgname))
  # Because we use useDynLib() in NAMESPCE this is not needed.
  # library.dynam("q4r", pkgname, lib.loc = libname, verbose = TRUE )
  # load.q()
}

.onUnload <- function(libpath) {
    # libpath = "/usr/local/lib/R/site-library"
    # library.dynam.unload("q4r", libpath)
}

.onAttach <- function(libname, pkgname) {
  packageStartupMessage("This is a pre-release. The interface might change...\n")
}



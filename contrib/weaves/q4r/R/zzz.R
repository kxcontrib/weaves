# Manual version
load.q <- function() {
  lib.loc = paste(.libPaths()[[1]], "q4r", "libs", "q4r.so", sep="/")
  dyn.load(lib.loc)
}

.First.lib <- function(lib, pkg) {
  # not called because this package has a namespace
}

.onLoad <- function(libname, pkgname) {
  cat("This is a pre-release. The interface might change...\n")
  # cat(paste(libname, pkgname))
  # cat("This is a pre-release. The interface might change...\n")
  library.dynam("q4r", pkgname, lib.loc = libname, verbose = TRUE )
  # load.q()
}

.onAttach <- function(libname, pkgname) {
  # cat("This is a pre-release. The interface might change...\n")
  # library.dynam("qserver", pkg, lib, lib.loc = .libPaths()[[1]] )
  # load.q()
}



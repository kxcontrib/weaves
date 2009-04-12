load.q <- function() {
  dyn.load(paste(.libPaths()[[1]], "qserver.so", sep="/"))
}

.First.lib <- function(lib, pkg) {
  library.dynam("qserver", pkg, lib, lib.loc = .libPaths()[[1]] )
}

.onLoad <- function(libname, pkgname) {
  cat("This is a pre-release. The interface might change...\n")
  # library.dynam("qserver", pkg, lib, lib.loc = .libPaths()[[1]] )
  load.q()
}



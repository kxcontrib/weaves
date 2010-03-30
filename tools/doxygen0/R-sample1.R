##' @file R-sample1.R
##' @brief This is a sample of a script
##' 
##' Has mostly calls and instantiations.
##' Some results and scripting.
##' @note
##' This file has some comments to explain @brief and . (full stop). This is a
##' doxygen caveat.
##' @see pkg

## Undocumented
library(pkg)

##' test function returns one (no full stop not brief)
##' @param car input variable
##' @return one

scripted1 <- function(car) {
  n=car
}

##' function no meta fields (full stop means brief).
scripted2 <- function(car) {
  n=car
}

##' function no meta fields with blank line does not force this as brief
##'
scripted3 <- function(car) {
  n=car
}

scripted4 <- function(car) { # undocumented
  n=car
}

if(!exists("Sys.setenv", mode = "function")) # pre R-2.5.0, use "old form"
    Sys.setenv <- Sys.putenv

##' @var type var1
##' @brief A script static.
var1 <- c(10, 20)

##' Some script's twists.
a=d
subfunct(a)
b=doxytest(g)
  
  

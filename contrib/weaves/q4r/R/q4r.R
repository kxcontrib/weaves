##' @brief Q/kdb for R 
##' @file q4r.R

open.q <- function(host="localhost", port=1444, user=NULL, hsym = NULL,
                   verbose = getOption("verbose")) {
  if(!is.null(hsym))
    host <- (unlist(strsplit(hsym, ":")))[[2]]

  if(!is.null(hsym))
    port <- as.integer((unlist(strsplit(hsym, ":")))[[3]])

  if(is.null(host) || is.na(host)) host <- "localhost"
  if(is.null(port) || is.na(port)) port <- 1444

  parameters <- list(host, as.integer(port), user)
  if(verbose) print(parameters)
  h <- .Call("kx_r_open_connection", parameters, "q4r")
  assign(".k.h", h, envir = .GlobalEnv)
  h
}

close.q <- function(connection = get(".k.h", envir = .GlobalEnv)) {
    if(is.null(connection)) return(NULL)
    .Call("kx_r_close_connection", as.integer(connection))
}

execute.q <- function(connection = get(".k.h", envir = .GlobalEnv), query) {
        .Call("kx_r_execute", as.integer(connection), query)
}

exec.q <- function(query, connection = get(".k.h", envir = .GlobalEnv),
                   host="localhost", port=1444, user=NULL) {
  opened <- FALSE
  if(missing(connection) || is.null(connection) || is.na(connection)) {
	connection <- open.q(host, port, user) 
        opened <- TRUE
  }
  a <- execute.q(connection, query)
  if(opened) close.q(connection)
  a
}



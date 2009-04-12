##' @brief Q/kdb for R 
##' @file q4r.R

open.q <- function(host="localhost", port=1444, user=NULL) {
	if(is.null(host) || is.na(host)) host <- "localhost"
	if(is.null(port) || is.na(port)) port <- 1444

         parameters <- list(host, as.integer(port), user)
         .Call("kx_r_open_connection", parameters)
}

close.q <- function(connection) {
        .Call("kx_r_close_connection", as.integer(connection))
}

execute.q <- function(connection, query) {
        .Call("kx_r_execute", as.integer(connection), query)
}

exec.q <- function(query, connection, host="localhost", port=1444, user=NULL) {
  opened <- FALSE
  if(missing(connection)) {
	connection <- open.q(host, port, user) 
        opened <- TRUE
  }
  a <- execute.q(connection, query)
  if(opened) close.q(connection)
  a
}



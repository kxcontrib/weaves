\name{open.q}
\alias{close.q}
\alias{execute.q}
\alias{exec.q}

\title{Access a q/kdb+ time-series database server}

\description{
 Open a connection to and submit queries on a remote q/kdb+ server
}

\usage{
open.q(host = "localhost", port = 1444, user = NULL)
close.q(connection)
execute.q(connection, query)
exec.q(connection, query, host = "localhost", port = 1444, user = NULL)
}

\arguments{
  \item{host}{string of the hostname of the server}
  \item{port}{port number of the server}
  \item{user}{user credentials for the server}
  \item{connection}{the connection returned by open.q}
  \item{query}{String of the query to submit to the server}
}

\details{
  Returns tables and results from a q/kdb+ server.
  It uses the rserver.so object from code.kx.com. This needs to be obtained, built and installed in
  the first of the .libPaths() directories.
}

\value{
  open.q() returns the connection object to be used with the other calls.
}

\references{
  \url{http://www.bigfoot.com/~Walter.Eaves}
}

\author{Walter Eaves}

\examples{

# Complete sequence
conn <- open.q(host = "db1.mydomain.co.uk", port = 15001)
execute.q(conn, "\\a")
close.q(conn)

# All-in-one on localhost:1444
exec.q("\\a")

}

\keyword{database}

\name{open.q}
\alias{open.q}

\title{Access a q/kdb+ time-series database server}

\description{
 Open a connection to a remote q/kdb+ server
}

\usage{
 handle <- open.q(host, port, user, hsym, verbose)
}

\arguments{
  \item{host}{string of the hostname of the server, default is localhost}
  \item{port}{port number of the server}
  \item{user}{user credentials for the server}
  \item{hsym}{colon concatenated string of host and port}
}

\details{
  Opens a connection to the database at host and port.
  The handle is stored in the global environment as ".k.h"
}

\value{
  open.q() returns the connection object to be used with the other calls.
}

\references{
  \url{http://code.kx.com/wsvn/code/cookbook_code/r/l64_qserver}
  \url{http://www.bigfoot.com/~Walter.Eaves}
}

\note{
  The packaging all I did. The code is from the KX cookbook.
}

\author{Walter Eaves}

\seealso{
\code{\link{close.q}}, ~~~
}

\examples{

# Complete sequence
conn <- open.q(host = "db1.mydomain.co.uk", port = 15001)
execute.q(conn, "\\a")
close.q(conn)

# All-in-one on localhost:1444
exec.q("\\a")

}

\keyword{database}

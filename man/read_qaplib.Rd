\name{read_qaplib}
\alias{read_qaplib}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Read QAPLIB Files}
\description{
Reads example file in the format used by QAPLIB.
}
\usage{
read_qaplib(file)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{file}{ file name. }
}
\details{
Problems end with the extension \code{.dat} and solutions with \code{.sln}.
The code tries to read the problem and, if available in the same directory,
it also reads the solution and the known optimal value from the
solution file.

The package contains a copy of the problem instances and solutions
from QAPLIB. The data is stored in the package in directory \code{qaplib}.
}
\value{
Returns a list with the components
  \item{D}{ distance matrix. }
  \item{W}{ weight matrix. }
  \item{solution}{ a known optimal solution (if available). }
  \item{opt}{ known optimal value (if available). }
}
\references{
R.E. Burkard, E. Cela, S.E. Karisch and F. Rendl,
QAPLIB - A Quadratic Assignment Problem Library,
\url{http://anjos.mgi.polymtl.ca/qaplib/}
}
\author{
Michael Hahsler
}
\examples{
## load a QAPLIB problem instance
p <- read_qaplib(system.file("qaplib", "had12.dat", package="qap"))
p

## list all QAPLIB instances
dir(system.file("qaplib", package="qap"), pattern = "*.dat")
}
\keyword{ manip }

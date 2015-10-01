\name{qap}
\alias{qap}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Solve Quadratic Assignment Problems (QAP)
}
\description{
This function implements Quadratic Assignment Problems (QAP) heuristics.
Currently there is only a simulated annealing heuristic available,
but more will be added in the future.
}
\usage{
qap(A, B, method = NULL, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{A}{ a symmetric integer matrix with weights/flows between pairs
      facilities. }
  \item{B}{ a symmetric integer matrix with distances between pairs of
      locations.}
  \item{method}{ a character string indicating the used solver. Defaults
    to \code{"SA"}, the currently only available method. }
  \item{...}{ further arguments are passed on to the solver (see details). }
}
\details{
The objective of the QAP is to find the best facility to location assignment.
The assignment is represented by a permutation matrix \eqn{X}{X} and
the objective is

\deqn{\mathrm{min}_{X \in \Pi}\; tr(AXBX^T)}{min_{pi \in PI} tr(AXBX^T)}

The problem is known to be NP-hard. This function implements the simple
simulated annealing heuristic described by Burkard and Rendl (1984).
The code is based on Rendl's FORTRAN implementation of the algorithm available
at the QAPLIB Web site.

The solver has the additional arguments
\code{miter = 2 * nrow(D), fiter = 1.1,
  ft = 0.5} and \code{rep = 10L}
\describe{
  \item{miter}{ integer; number of iterations at fixed temperature. }
  \item{fiter}{ multiplication factor for miter after miter
      random transposition trials. }
  \item{ft}{ multiplication factor for t after miter random
      transposition trials (between 0 and 1).}
  \item{rep}{ integer; number of restarts. }
}
}
\value{
Returns an integer vector with facility to location assignments. The
objective function value is provided as attribute \code{"obj"}.
}
\references{
R.E. Burkard and F. Rendl. A thermodynamically motivated
simulation procedure for combinatorial optimization problems.
\emph{European Journal of Operations Research,} 17(2):169-174, 1984.

R.E. Burkard, E. Cela, S.E. Karisch and F. Rendl,
QAPLIB - A Quadratic Assignment Problem Library,
\url{http://anjos.mgi.polymtl.ca/qaplib/}
}
\author{
Michael Hahsler
}
%\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
%}
\examples{
## load the had12 QAPLIB problem
p <- read_qaplib(system.file("qaplib", "had12.dat", package="qap"))
p


## run 5 repetitions verbose
a <- qap(p$A, p$B, rep = 5, verbose = TRUE)
a

## compare with known optimum (% above optimum)
(attr(a, "obj") - p$opt)/p$opt * 100

## run more repetitions quietly
a <- qap(p$A, p$B, rep = 100)
a

## compare with known optimum (% above optimum)
(attr(a, "obj") - p$opt)/p$opt * 100
}
\keyword{optim}

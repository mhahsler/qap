#' Solve a Quadratic Assignment Problem
#'
#' Solve a quadratic assignment problem (QAP) with a simulated annealing
#' heuristic. [qap.obj()] calculates the objective value of an assignment.
#'
#' @param A A symmetric matrix of nonnegative flows between facilities.
#' @param B A symmetric matrix of nonnegative distances between locations.
#' @param method Solver name. Currently only `"SA"` is available.
#' @param ... Additional arguments passed to the simulated annealing solver.
#'   See Details.
#' @param o A permutation vector assigning facilities to locations.
#'
#' @details
#' Given flows between facilities in `A` and distances between locations in
#' `B`, the QAP seeks an assignment that minimizes the sum of flow times
#' distance. For an assignment represented by a permutation matrix \eqn{X},
#' the objective is
#' \deqn{\min_{X \in \Pi}\; \mathrm{tr}(AXBX^T)}
#'
#' The QAP originated as a facility location problem (Koopmans and Beckmann,
#' 1957) and also has applications in data analysis (Hubert and Schultz, 1976).
#' It is NP-hard. The solver uses the simulated annealing heuristic of Burkard
#' and Rendl (1984), based on Rendl's Fortran implementation from QAPLIB.
#' The authors suggest it can produce heuristic solutions for problems with
#' up to 256 objects, although the implementation does not enforce this limit.
#'
#' Additional solver arguments are:
#' \describe{
#'   \item{\code{rep}}{Number of restarts; default \code{1L}.}
#'   \item{\code{miter}}{Number of iterations at a fixed temperature; default
#'     \code{2 * nrow(A)}.}
#'   \item{\code{fiter}}{Factor by which \code{miter} grows after each cooling
#'     step; default \code{1.1}.}
#'   \item{\code{ft}}{Factor by which the temperature decreases after each
#'     cooling step; default \code{0.5} (between 0 and 1).}
#'   \item{\code{maxsteps}}{Maximum number of cooling steps; default
#'     \code{50L}.}
#'   \item{\code{verbose}}{Print progress; default \code{FALSE}.}
#' }
#'
#' @return `qap()` returns an integer vector of facility to location
#'   assignments with the objective value in its `"obj"` attribute.
#'   `qap.obj()` returns the objective value for permutation `o`.
#' @references
#' Burkard, R. E. and Rendl, F. (1984). A thermodynamically motivated
#' simulation procedure for combinatorial optimization problems.
#' \emph{European Journal of Operational Research}, 17(2), 169-174.
#' \doi{10.1016/0377-2217(84)90231-5}
#'
#' Koopmans, T. C. and Beckmann, M. (1957). Assignment problems and the
#' location of economic activities. \emph{Econometrica}, 25(1), 53-76.
#' \doi{10.2307/1907742}
#'
#' Hubert, L. and Schultz, J. (1976). Quadratic assignment as a general data
#' analysis strategy. \emph{British Journal of Mathematical and Statistical
#' Psychology}, 29(2), 190-241.
#' \doi{10.1111/j.2044-8317.1976.tb00714.x}
#' @seealso [read_qaplib()]
#' @examples
#' p <- read_qaplib(system.file("qaplib", "had12.dat", package = "qap"))
#' a <- qap(p$A, p$B, verbose = TRUE)
#' a
#' qap.obj(p$A, p$B, a)
#' (attr(a, "obj") - p$opt) / p$opt * 100
#' @export
#' @useDynLib qap
qap <- function(A, B, method = NULL, ...) {
  if(is.null(method)) method <- "SA"

  methods <- c("SA")
  method <- methods[pmatch(tolower(method), tolower(methods))]
  if(is.na(method)) stop("Unknown method. Available methods are: ",
    paste(methods, collapse = ", "))

  if(method == "SA") qapSA(A, B, ...)
  else stop("Unknown method. Available methods are: ",
    paste(methods, collapse = ", "))
}

#' @rdname qap
#' @export
qap.obj <- function(A, B, o) {
  sum(diag(A%*%B[o,o]))
}

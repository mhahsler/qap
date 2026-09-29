#' Solve a Quadratic Assignment Problem
#'
#' Solve a quadratic assignment problem (QAP) with a simulated annealing
#' heuristic. [qap.obj()] calculates the objective value of an assignment.
#'
#' @param A A numeric matrix of flows between facilities. For `qap()`, it
#'   must be at least 2 by 2, symmetric, nonnegative, and finite.
#' @param B A numeric matrix of distances between locations. For `qap()`, it
#'   must have the same dimensions as `A` and be symmetric, nonnegative, and
#'   finite.
#' @param method Solver name. Currently only `"SA"` is available.
#' @param ... Additional arguments passed to the simulated annealing solver.
#'   See Details.
#' @param o A permutation of `1:nrow(A)` assigning facilities to locations.
#'
#' @details
#' The problem is to assign \eqn{n} facilities to \eqn{n} locations to minimize total transportation or 
#' interaction costs.
#' Required flows between the facilities are represented by the matrix \eqn{A} and distances between locations
#' is given in matrix \eqn{B}. The QAP seeks an assignment that minimizes the 
#' sum of flows times distance. 
#' For an assignment represented by a \eqn{n \times n}{n x n} permutation matrix \eqn{X} used to
#' assign the facilities to the locations in the order given by the 
#' permutation,
#' the objective can be written as 
#' 
#' \deqn{\min_{X \in \Pi}\; \mathrm{tr}(AXB^TX^T)}{min_(X in Pi) tr(AXB'X')}
#'
#' where \eqn{\Pi}{Pi} is the set of all valid \eqn{n \times n}{n x n} permutation matrices.
#' Note that for symmetric distances, the distance matrix \eqn{B} does not need to be transposed. 
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
#'   \item{\code{rep}}{Positive integer number of restarts; default \code{1L}.}
#'   \item{\code{miter}}{Positive integer number of iterations at a fixed temperature; default
#'     \code{2 * nrow(A)}.}
#'   \item{\code{fiter}}{Factor of at least 1 by which \code{miter} grows
#'     after each cooling step; default \code{1.1}.}
#'   \item{\code{ft}}{Factor by which the temperature decreases after each
#'     cooling step; default \code{0.5} (strictly between 0 and 1).}
#'   \item{\code{maxsteps}}{Positive integer maximum number of cooling steps; default
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

  if(!is.character(method) || length(method) != 1L || is.na(method) ||
     !nzchar(method))
    stop("method must be a single solver name.", call. = FALSE)

  methods <- c("SA")
  method <- methods[pmatch(tolower(method), tolower(methods))]
  if(is.na(method)) stop("Unknown method. Available methods are: ",
    paste(methods, collapse = ", "), call. = FALSE)

  if(method == "SA") qapSA(A, B, ...)
  else stop("Unknown method. Available methods are: ",
    paste(methods, collapse = ", "))
}

#' @rdname qap
#' @export
qap.obj <- function(A, B, o) {
  matrices <- validate_qap_matrices(A, B)
  A <- matrices$A
  B <- matrices$B
  n <- nrow(A)
  if(!is.numeric(o) || !is.null(dim(o)) || length(o) != n || anyNA(o) ||
     any(!is.finite(o)) || any(o != trunc(o)) || any(o < 1 | o > n) ||
     !identical(sort(as.integer(o)), seq_len(n)))
    stop("o must be a permutation of 1:nrow(A).", call. = FALSE)

  sum(diag(A%*%B[o,o]))
}

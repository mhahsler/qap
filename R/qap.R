#' Solve a Quadratic Assignment Problem
#'
#' Solve a quadratic assignment problem (QAP) with a simulated annealing or
#' robust tabu search heuristic. [qap.obj()] calculates the objective value of an assignment.
#'
#' @param A A numeric matrix of flows between facilities. For `qap()`, it
#'   must be at least 2 by 2, symmetric, nonnegative, and finite.
#' @param B A numeric matrix of distances between locations. For `qap()`, it
#'   must have the same dimensions as `A` and be symmetric, nonnegative, and
#'   finite.
#' @param method Solver name: `"SA"` (simulated annealing, the default) or
#'   `"RoTS"` (robust tabu search).
#' @param ... Additional arguments passed to the selected solver.
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
#' It is NP-hard. Two heuristics are available.
#'
#' ## Simulated Annealing
#' 
#' `method = "SA"` uses the simulated annealing heuristic of Burkard
#' and Rendl (1984), based on Rendl's Fortran implementation from QAPLIB.
#' The authors suggest it can produce heuristic solutions for problems with
#' up to 256 objects, although the implementation does not enforce this limit.
#'
#' Additional arguments for `method = "SA"` are:
#' \describe{
#'   \item{\code{rep}}{Positive integer number of restarts. 
#'      More restarts can help with local optima. Default: \code{1L}.}
#'   \item{\code{miter}}{Positive integer number of iterations at a fixed temperature. 
#'      Increasing miter typically leads to modest reduction
#'      in the optimality gap while increasing runtime. 
#'      Default: \code{2 * nrow(A)}.}
#'   \item{\code{fiter}}{Factor of at least 1 by which \code{miter} grows
#'     after each cooling step. Larger values lead to very long runtimes. 
#'     Default \code{1.1}.}
#'   \item{\code{ft}}{Factor by which the temperature decreases after each
#'     cooling step. When increasing this value, `maxsteps` also needs to be increased. 
#'     Default \code{0.5} (strictly between 0 and 1).}
#'   \item{\code{maxsteps}}{Positive integer maximum number of cooling steps.
#'     The search also stops earlier once it has frozen, i.e., the
#'     objective value did not change during a whole step. With the default
#'     cooling rate this typically happens for problems with less than 
#'     150 objects before the default `maxsteps` of 50 is reached, however, larger problems
#'     can benefit from increasing `maxsteps`.
#'     Default \code{50L}.}
#'   \item{\code{verbose}}{Print the parameter settings and, for each
#'     restart, the best and current objective values, the number of cooling
#'     steps used, the final temperature, and the run time; default \code{FALSE}.}
#' }
#' 
#' A good starting point for experiments is to set `maxsteps` very large 
#' (e.g., 100000) and then slow down cooling by increasing `ft` from 0.5 
#' in 0.1 steps towards 1.
#' Use `verbose = TRUE` to see the algorithm's behavior given the parameters
#' and if `maxsteps` stop simulated annealing too early with a high final 
#' temperature.
#'
#'
#' ## Robust Tabu Search
#' 
#' `method = "RoTS"` uses the robust tabu search of Taillard (1991). It
#' repeatedly moves to the best pairwise exchange of two facilities that is
#' not tabu, where a tabu tenure that varies randomly around `tenure`
#' iterations prevents facilities from returning to recently used locations.
#' Moves are accepted regardless of tabu status if they give a new best
#' solution or place a facility at a location it has not used for more than
#' `aspiration` iterations. Random numbers come from R's generator, so results
#' can be reproduced with [set.seed()].
#'
#' Additional arguments for `method = "RoTS"` are:
#' \describe{
#'   \item{\code{rep}}{Positive integer number of restarts from random
#'     permutations. More restarts reduce the dependence on the starting
#'     permutation. Default \code{1L}.}
#'   \item{\code{iter}}{Positive integer number of tabu search iterations
#'     per restart. The run time grows linearly with `iter`. Default
#'     \code{100 * nrow(A)}.}
#'   \item{\code{tenure}}{Positive integer mean tabu tenure. The actual
#'     tenure is drawn uniformly from 0.9 to 1.1 times this value. A longer
#'     tenure forbids more moves and pushes the search further away from the
#'     current region, a shorter tenure makes it more greedy. Default
#'     \code{nrow(A)}.}
#'   \item{\code{aspiration}}{Nonnegative number of iterations after which
#'     an unused placement may override the tabu status. Default
#'     \code{5 * nrow(A)^2}.}
#'   \item{\code{verbose}}{Print the parameter settings and, for each
#'     restart, the best and current objective values, the iteration at which
#'     the best solution was found (`best_iter`), the number of tabu moves
#'     taken because of aspiration (`aspired`), and the run time; default
#'     \code{FALSE}.}
#' }
#'
#' Unlike simulated annealing, tabu search always runs for `iter` iterations. 
#' The tabu tenure controls how strongly the
#' search is pushed to explore and stays fixed during the run.
#' The defaults follow Taillard (1991) and worked well 
#' for many small QAPLIB problems where small changes of the parameters 
#' `tenure` and `aspiration` often make very little difference. 
#' 
#' Use `verbose = TRUE`
#' to check `best_iter`: if the best solution is found close to `iter`, the
#' search was still improving and `iter` should be increased. If it is found
#' much earlier, the rest of the run added little, and a smaller `iter` with
#' more restarts may be more effective.
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
#' Taillard, E. (1991). Robust taboo search for the quadratic assignment
#' problem. \emph{Parallel Computing}, 17(4-5), 443-455.
#' \doi{10.1016/S0167-8191(05)80147-4}
#'
#' Hubert, L. and Schultz, J. (1976). Quadratic assignment as a general data
#' analysis strategy. \emph{British Journal of Mathematical and Statistical
#' Psychology}, 29(2), 190-241.
#' \doi{10.1111/j.2044-8317.1976.tb00714.x}
#' @seealso [read_qaplib()]
#' @examples
#' set.seed(1234)
#' p <- read_qaplib(system.file("qaplib", "had12.dat", package = "qap"))
#' cat("Optimal solution:", p$opt)
#' 
#' a <- qap(p$A, p$B, verbose = TRUE, rep = 5)
#' a
#' cat("optimality gap:", (attr(a, "obj") - p$opt) / p$opt * 100, "%")
#'
#' # robust tabu search often finds the optimal solution
#' a <- qap(p$A, p$B, method = "RoTS", rep = 5, verbose = TRUE)
#' a
#' cat("optimality gap:", (attr(a, "obj") - p$opt) / p$opt * 100, "%")
#' @export
#' @useDynLib qap
qap <- function(A, B, method = NULL, ...) {
  if(is.null(method)) method <- "SA"

  if(!is.character(method) || length(method) != 1L || is.na(method) ||
     !nzchar(method))
    stop("method must be a single solver name.", call. = FALSE)

  methods <- c("SA", "RoTS")
  method <- methods[pmatch(tolower(method), tolower(methods))]
  if(is.na(method)) stop("Unknown method. Available methods are: ",
    paste(methods, collapse = ", "), call. = FALSE)

  if(method == "SA") qapSA(A, B, ...)
  else if(method == "RoTS") qapRoTS(A, B, ...)
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

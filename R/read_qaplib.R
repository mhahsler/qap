
#' Read QAPLIB Files
#'
#' Read a problem instance and, when available, its solution from QAPLIB files.
#'
#' @param file Path to a QAPLIB problem file with a `.dat` extension.
#' @details If a `.sln` file with the same base name exists in the same
#'   directory, the function also reads its solution and objective value.
#'   Zero-based solutions are converted to R's one-based indexing.
#'   The package includes QAPLIB instances and solutions in its `qaplib`
#'   directory.
#' @return A list with `A` (the flow matrix), `B` (the distance matrix),
#'   `solution` (a known solution, if available), and `opt` (its objective
#'   value, if available). The last two components are `NULL` when no solution
#'   file exists.
#' @references Burkard, R. E., Çela, E., Karisch, S. E., and Rendl, F.
#'   [QAPLIB: A Quadratic Assignment Problem Library](https://coral.ise.lehigh.edu/data-sets/qaplib/).
#' @examples
#' p <- read_qaplib(system.file("qaplib", "had12.dat", package = "qap"))
#' p
#' dir(system.file("qaplib", package = "qap"), pattern = "\\.dat$")
#' @export
read_qaplib <- function(file) {
  if(!is.character(file) || length(file) != 1L || is.na(file) ||
     !nzchar(file) || !file.exists(file) || dir.exists(file))
    stop("file must name an existing QAPLIB problem file.", call. = FALSE)

  dat <- scan(file, what = double(), quiet = TRUE)
  if(length(dat) < 1L || !is.finite(dat[1]) || dat[1] < 1 ||
     dat[1] != trunc(dat[1]) ||
     dat[1] > sqrt((.Machine$integer.max - 1) / 2))
    stop("Invalid QAPLIB problem size in ", file, ".", call. = FALSE)
  n <- as.integer(dat[1])
  if(length(dat) != 1 + 2 * n * n || any(!is.finite(dat)) ||
     any(dat != trunc(dat)) || any(abs(dat) > .Machine$integer.max))
    stop("Invalid QAPLIB problem data in ", file, ".", call. = FALSE)
  dat <- as.integer(dat)

  A <- matrix(dat[seq.int(2L, n*n + 1L)], nrow = n, byrow = TRUE)
  B <- matrix(dat[seq.int(n*n + 2L, 2L*n*n + 1L)], nrow = n, byrow = TRUE)

  # read solution if available
  sol <- NULL
  opt <- NULL
  file_sol <- if(grepl("\\.dat$", file)) sub("\\.dat$", ".sln", file) else NULL
  if(!is.null(file_sol) && file.exists(file_sol)) {
    dat <- scan(file_sol, what = double(), quiet = TRUE)
    if(length(dat) != n + 2L || any(!is.finite(dat)) || dat[1] != n)
      stop("Invalid QAPLIB solution data in ", file_sol, ".", call. = FALSE)
    sol <- dat[-(1:2)]
    if(any(sol != trunc(sol)))
      stop("Invalid QAPLIB solution permutation in ", file_sol, ".",
           call. = FALSE)
    if(identical(sort(sol), as.double(seq.int(0L, n - 1L))))
      sol <- sol + 1
    if(!identical(sort(sol), as.double(seq_len(n))))
      stop("Invalid QAPLIB solution permutation in ", file_sol, ".",
           call. = FALSE)
    sol <- as.integer(sol)
    opt <- dat[2]
  }


  list(A=A, B=B, solution = sol, opt = opt)
}

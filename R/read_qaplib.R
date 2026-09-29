
#' Read QAPLIB Files
#'
#' Read a problem instance and, when available, its solution from QAPLIB files.
#'
#' @param file Path to a QAPLIB problem file with a `.dat` extension.
#' @details If a `.sln` file with the same base name exists in the same
#'   directory, the function also reads its solution and objective value.
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
  if(!file.exists(file)) stop("file ", file, " does not exist!")

  dat <- as.integer(scan(file, quiet = TRUE))
  n <- dat[1]

  A <- matrix(dat[2:(n*n+1L)], ncol = n, nrow = n, byrow = TRUE)
  B <- matrix(dat[(n*n+2L):(n*n+2L+n*n-1L)], ncol = n, nrow = n, byrow = TRUE)

  # read solution if available
  sol <- NULL
  opt <- NULL
  file_sol <- sub(".dat", ".sln", file)
  if(file.exists(file_sol)) {
    dat <- scan(file_sol, quiet = TRUE)
    sol <- dat[-(1:2)]
    opt <- dat[2]
  }


  list(A=A, B=B, solution = sol, opt = opt)
}

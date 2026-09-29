## Calls FORTRAN implementation of:
## R.E. BURKARD and F. RENDL. A thermodynamically motivated
## simulation procedure for combinatorial optimization problems.
## European Journal of Operational Research, 17(2):169-174, 1984.

qapSA <- function(A, B, rep = 1L, miter = 2*nrow(A), fiter = 1.1, ft = .5,
   maxsteps = 50L, verbose = FALSE) {
  matrices <- validate_qap_matrices(A, B, min_n = 2L, symmetric = TRUE,
                                    nonnegative = TRUE)
  A <- matrices$A
  B <- matrices$B

  storage.mode(A) <- "double"
  storage.mode(B) <- "double"
  n <- nrow(A)
  rep <- validate_integer_scalar(rep, "rep")
  miter <- validate_integer_scalar(miter, "miter")
  maxsteps <- validate_integer_scalar(maxsteps, "maxsteps")
  if(!is.numeric(fiter) || length(fiter) != 1L || is.na(fiter) ||
     !is.finite(fiter) || fiter < 1)
    stop("fiter must be a finite number of at least 1.", call. = FALSE)
  if(!is.numeric(ft) || length(ft) != 1L || is.na(ft) ||
     !is.finite(ft) || ft <= 0 || ft >= 1)
    stop("ft must be a finite number between 0 and 1 (exclusive).",
         call. = FALSE)
  if(!is.logical(verbose) || length(verbose) != 1L || is.na(verbose))
    stop("verbose must be TRUE or FALSE.", call. = FALSE)

  if(verbose) cat("Simulated annealing heuristic by Burkard and Rendl.\n")
  if(verbose) cat(sprintf("%5s %10s %10s\n", "rep", "best_obj", "current_obj"))

  best_perm <- NULL
  best_obj <- Inf

  ## we do repetitions in R (not in the FORTRAN code)
  ## we start with a random permutation in perm
  for(i in seq_len(rep)) {
    res <- .Fortran("qaph4", n = n, a = A, b = B,
      miter = as.integer(miter), fiter = as.double(fiter),
      ft = as.double(ft), ope = integer(n), ol = double(1), perm = sample(n),
      maxsteps = as.integer(maxsteps), PACKAGE = "qap")


    if(res$ol < best_obj) {
      best_obj <- res$ol
      best_perm <- res$ope
    }

    if(verbose) cat(sprintf("%5i %10.0f %10.0f\n", i, best_obj, res$ol))

  }

  attr(best_perm, "obj") <- best_obj
  best_perm
}

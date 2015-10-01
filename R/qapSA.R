## Calls Fortran implentation of:
## R.E. BURKARD and F. RENDL. A thermodynamically motivated
## simulation procedure for combinatorial optimization problems.
## European Journal of Operations Research, 17(2):169-174, 1984.

qapSA <- function(A, B, miter = 2*nrow(A), fiter = 1.1, ft = .5,
  rep = 10L, verbose = FALSE) {
  storage.mode(A) <- "integer"
  storage.mode(B) <- "integer"
  n <- nrow(A)

  if(any(dim(A) != n) || any(dim(B) != n)) stop("Matrix do not conform!")

  if(ft<0 || ft>=1) stop("ft needs to be in (0 ,1).")

  if(verbose) cat("Simulated Annealing Heuristic by Burkart and Rendl.\n")
  if(verbose) cat(sprintf("%5s %10s %10s\n", "rep", "best_obj", "current_obj"))

  best_perm <- NULL
  best_obj <- .Machine$integer.max

  ## we do repetitions in R (not in the FORTRAN code)
  for(i in 1:rep) {
    res <- .Fortran("qaph4", n = n, a = A, b = B,
      c = matrix(0L, nrow=n ,ncol=n),
      miter = as.integer(miter), fiter = as.double(fiter), ft = as.double(ft),
      rep = 1L, maxdim = n, ope = integer(n), ol = integer(1),
      bool = integer(n), perm = integer(n),
      PACKAGE = "qap")


    if(res$ol < best_obj) {
      best_obj <- res$ol
      best_perm <- res$ope
    }

    if(verbose) cat(sprintf("%5i %10i %10i\n", i, best_obj, res$ol))

  }

  attr(best_perm, "obj") <- best_obj
  best_perm
}

## Calls C implementation of:
## E. Taillard. Robust taboo search for the quadratic assignment problem.
## Parallel Computing, 17(4-5):443-455, 1991.

qapRoTS <- function(A, B, rep = 1L, iter = 100L * nrow(A),
                    tenure = nrow(A), aspiration = 5 * nrow(A)^2,
                    verbose = FALSE) {
  matrices <- validate_qap_matrices(A, B, min_n = 2L, symmetric = TRUE,
                                    nonnegative = TRUE)
  A <- matrices$A
  B <- matrices$B

  storage.mode(A) <- "double"
  storage.mode(B) <- "double"
  n <- nrow(A)
  rep <- validate_integer_scalar(rep, "rep")
  iter <- validate_integer_scalar(iter, "iter")
  tenure <- validate_integer_scalar(tenure, "tenure")
  if(!is.numeric(aspiration) || length(aspiration) != 1L ||
     is.na(aspiration) || !is.finite(aspiration) || aspiration < 0)
    stop("aspiration must be a finite number of at least 0.", call. = FALSE)
  if(!is.logical(verbose) || length(verbose) != 1L || is.na(verbose))
    stop("verbose must be TRUE or FALSE.", call. = FALSE)

  if(verbose) {
    cat("Robust tabu search by Taillard.\n")
    cat(sprintf(paste0("Parameters: n = %d, rep = %d, iter = %d, tenure = %d, ",
                       "aspiration = %g\n"),
                n, rep, iter, tenure, aspiration))
  }
  if(verbose) cat(sprintf("%5s %10s %12s %10s %9s %8s\n", "rep", "best_obj",
                          "current_obj", "best_iter", "aspired", "time"))

  best_perm <- NULL
  best_obj <- Inf

  ## each repetition starts from a random permutation
  for(i in seq_len(rep)) {
    start <- proc.time()[["elapsed"]]
    res <- .Call("qap_rots", A, B, sample(n), iter, tenure,
                 as.double(aspiration), PACKAGE = "qap")

    if(res[[2L]] < best_obj) {
      best_obj <- res[[2L]]
      best_perm <- res[[1L]]
    }

    if(verbose) cat(sprintf("%5i %10.0f %12.0f %10i %9i %7.3fs\n", i,
                            best_obj, res[[2L]], res[[3L]], res[[4L]],
                            proc.time()[["elapsed"]] - start))
  }

  attr(best_perm, "obj") <- best_obj
  best_perm
}

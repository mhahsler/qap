validate_qap_matrices <- function(A, B, min_n = 1L, symmetric = FALSE,
                                  nonnegative = FALSE) {
  A <- as.matrix(A)
  B <- as.matrix(B)

  if(!is.numeric(A) || !is.numeric(B) || length(dim(A)) != 2L ||
     length(dim(B)) != 2L)
    stop("A and B must be numeric matrices.", call. = FALSE)

  n <- nrow(A)
  if(n < min_n || ncol(A) != n || !identical(dim(B), c(n, n)))
    stop("A and B must be square matrices of the same size",
         if(min_n > 1L) " (at least 2 by 2)." else ".", call. = FALSE)

  if(any(!is.finite(A)) || any(!is.finite(B)))
    stop("A and B must contain only finite values.", call. = FALSE)

  if(symmetric && (!isSymmetric(A) || !isSymmetric(B)))
    stop("A and B must be symmetric.", call. = FALSE)

  if(nonnegative && (any(A < 0) || any(B < 0)))
    stop("A and B must contain only nonnegative values.", call. = FALSE)

  list(A = unname(A), B = unname(B))
}

validate_integer_scalar <- function(x, name, minimum = 1L) {
  if(!is.numeric(x) || length(x) != 1L || is.na(x) || !is.finite(x) ||
     x != trunc(x) || x < minimum || x > .Machine$integer.max)
    stop(name, " must be a finite integer of at least ", minimum, ".",
         call. = FALSE)
  as.integer(x)
}

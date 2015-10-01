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

qap.obj <- function(A, B, o) {
  n <- nrow(A)
  s <- 0
  for(i in 1:n) for(j in 1:n) s <- s+A[i,j]*B[o[i],o[j]]
  s
}

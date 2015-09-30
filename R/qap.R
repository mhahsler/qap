qap <- function(D, W, method = NULL, ...) {
  if(is.null(method)) method <- "SA"

  methods <- c("SA")
  method <- methods[pmatch(tolower(method), tolower(methods))]
  if(is.na(method)) stop("Unknown method. Available methods are: ",
    paste(methods, collapse = ", "))

  if(method == "SA") qapSA(D, W, ...)
  else stop("Unknown method. Available methods are: ",
    paste(methods, collapse = ", "))
}



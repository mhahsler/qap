test_that("the solver returns a valid assignment and objective", {
  p <- read_qaplib(system.file("qaplib", "had12.dat", package = "qap"))
  set.seed(42)
  assignment <- qap(p$A, p$B, rep = 2L)

  expect_identical(sort(as.integer(assignment)), seq_len(nrow(p$A)))
  expect_equal(unname(attr(assignment, "obj")), qap.obj(p$A, p$B, assignment))
})

test_that("qap.obj checks dimensions and the permutation", {
  A <- matrix(c(0, 2, 2, 0), 2)
  B <- matrix(c(0, 3, 3, 0), 2)

  expect_equal(qap.obj(A, B, c(2L, 1L)), 12)
  expect_error(qap.obj(A, B, 1L), "permutation")
  expect_error(qap.obj(A, B, c(1L, 1L)), "permutation")
  expect_error(qap.obj(A, B, c(0L, 1L)), "permutation")
  expect_error(qap.obj(A, B, c(1, 1.5)), "permutation")
  expect_error(qap.obj(A, B, c(1, NA)), "permutation")
  expect_error(qap.obj(A, B, c(1, Inf)), "permutation")
  expect_error(qap.obj(A, B, c(1, 1e100)), "permutation")
  expect_error(qap.obj(A, B, matrix(1:2, 2)), "permutation")
  expect_error(qap.obj(A, B, c("1", "2")), "permutation")
  expect_error(qap.obj(A, matrix(1, 3, 3), 1:2), "same size")
  expect_error(qap.obj(matrix(1, 2, 3), B, 1:2), "square")
  expect_error(qap.obj(matrix(NA_real_, 2, 2), B, 1:2), "finite")
})

test_that("qap rejects unsupported matrix input", {
  A <- matrix(c(0, 2, 2, 0), 2)
  B <- matrix(c(0, 3, 3, 0), 2)

  expect_error(qap(matrix("x", 2, 2), B), "numeric")
  expect_error(qap(matrix(1, 1, 1), matrix(1, 1, 1)), "at least 2")
  expect_error(qap(matrix(1, 2, 3), B), "square")
  expect_error(qap(A, matrix(1, 3, 3)), "same size")
  expect_error(qap(matrix(NA_real_, 2, 2), B), "finite")
  expect_error(qap(matrix(Inf, 2, 2), B), "finite")
  expect_error(qap(matrix(c(0, 1, 2, 0), 2), B), "symmetric")
  expect_error(qap(matrix(c(0, -1, -1, 0), 2), B), "nonnegative")
})

test_that("qap validates solver settings before calling Fortran", {
  A <- matrix(c(0, 2, 2, 0), 2)
  B <- matrix(c(0, 3, 3, 0), 2)

  bad_settings <- list(
    list(rep = 0), list(rep = 1.5), list(rep = NA_real_),
    list(miter = 0), list(maxsteps = 0),
    list(fiter = 0.5), list(fiter = Inf),
    list(ft = 0), list(ft = 1), list(ft = NA_real_),
    list(verbose = NA)
  )
  for(setting in bad_settings)
    expect_error(do.call(qap, c(list(A = A, B = B), setting)))

  expect_error(qap(A, B, method = NA_character_), "method")
  expect_error(qap(A, B, method = character()), "method")
  expect_error(qap(A, B, method = "unknown"), "Unknown method")
})

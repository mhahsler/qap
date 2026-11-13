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

test_that("robust tabu search returns a valid assignment and objective", {
  p <- read_qaplib(system.file("qaplib", "had12.dat", package = "qap"))
  set.seed(42)
  assignment <- qap(p$A, p$B, method = "RoTS", rep = 2L)

  expect_identical(sort(as.integer(assignment)), seq_len(nrow(p$A)))
  expect_equal(unname(attr(assignment, "obj")), qap.obj(p$A, p$B, assignment))
  expect_gte(attr(assignment, "obj"), p$opt)
})

test_that("robust tabu search finds known optima of small instances", {
  for(f in c("had12", "nug12", "chr12a")) {
    p <- read_qaplib(system.file("qaplib", paste0(f, ".dat"), package = "qap"))
    set.seed(1)
    a <- qap(p$A, p$B, method = "RoTS", rep = 5L, iter = 2000L)
    expect_equal(unname(attr(a, "obj")), p$opt)
  }
})

test_that("robust tabu search works for the smallest problem", {
  A <- matrix(c(0, 2, 2, 0), 2)
  B <- matrix(c(0, 3, 3, 0), 2)
  set.seed(1)
  a <- qap(A, B, method = "rots", iter = 5L, tenure = 1L)
  expect_identical(sort(as.integer(a)), 1:2)
  expect_equal(unname(attr(a, "obj")), 12)
})

test_that("robust tabu search is reproducible with a seed", {
  p <- read_qaplib(system.file("qaplib", "nug15.dat", package = "qap"))
  set.seed(7); a <- qap(p$A, p$B, method = "RoTS", iter = 300L)
  set.seed(7); b <- qap(p$A, p$B, method = "RoTS", iter = 300L)
  expect_identical(a, b)
})

test_that("robust tabu search validates settings", {
  A <- matrix(c(0, 2, 2, 0), 2)
  B <- matrix(c(0, 3, 3, 0), 2)

  bad_settings <- list(
    list(rep = 0), list(iter = 0), list(iter = 1.5), list(tenure = 0),
    list(aspiration = -1), list(aspiration = NA_real_),
    list(aspiration = Inf), list(verbose = NA)
  )
  for(setting in bad_settings)
    expect_error(do.call(qap, c(list(A = A, B = B, method = "RoTS"), setting)))
  expect_error(qap(matrix(c(0, 1, 2, 0), 2), B, method = "RoTS"), "symmetric")
})

test_that("verbose output shows the parameter settings", {
  p <- read_qaplib(system.file("qaplib", "had12.dat", package = "qap"))
  set.seed(1)
  expect_output(qap(p$A, p$B, rep = 2L, ft = 0.6, verbose = TRUE),
                "Parameters: n = 12, rep = 2, miter = 24.*ft = 0.6.*steps.*final_temp")
  expect_output(qap(p$A, p$B, method = "RoTS", iter = 50L, verbose = TRUE),
                "Parameters: n = 12, rep = 1, iter = 50, tenure = 12")
})

test_that("robust tabu search verbose output shows best iteration and aspiration", {
  p <- read_qaplib(system.file("qaplib", "had12.dat", package = "qap"))
  set.seed(1)
  expect_output(qap(p$A, p$B, method = "RoTS", iter = 50L, verbose = TRUE),
                "best_iter.*aspired")
})

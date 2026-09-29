test_that("bundled QAPLIB instances have consistent dimensions and solutions", {
  files <- list.files(system.file("qaplib", package = "qap"),
                      pattern = "\\.dat$", full.names = TRUE)
  expect_gt(length(files), 0L)

  for(file in files) {
    p <- read_qaplib(file)
    expect_identical(dim(p$A), dim(p$B), info = basename(file))
    expect_equal(nrow(p$A), ncol(p$A), info = basename(file))
    if(!is.null(p$solution))
      expect_identical(sort(p$solution), seq_len(nrow(p$A)),
                       info = basename(file))
  }
})

test_that("QAPLIB reader rejects malformed problem data", {
  file <- tempfile(fileext = ".dat")
  on.exit(unlink(file), add = TRUE)

  expect_error(read_qaplib(NA_character_), "file")
  expect_error(read_qaplib(character()), "file")
  expect_error(read_qaplib(file), "file")

  writeLines("", file)
  expect_error(read_qaplib(file), "problem size")
  writeLines("0 1 2", file)
  expect_error(read_qaplib(file), "problem size")
  writeLines("2 0 1 1", file)
  expect_error(read_qaplib(file), "problem data")
  writeLines("2 0 1 1 0 0 2 2 0 9", file)
  expect_error(read_qaplib(file), "problem data")
  writeLines("2 0 1 1 0 0 2 2 Inf", file)
  expect_error(read_qaplib(file), "problem data")
  writeLines("2 0 1.5 1 0 0 2 2 0", file)
  expect_error(read_qaplib(file), "problem data")
})

test_that("QAPLIB reader validates and normalizes solutions", {
  file <- tempfile(fileext = ".dat")
  solution_file <- sub("\\.dat$", ".sln", file)
  on.exit(unlink(c(file, solution_file)), add = TRUE)
  writeLines("2 0 1 1 0 0 2 2 0", file)

  expect_null(read_qaplib(file)$solution)
  writeLines("2 4 0 1", solution_file)
  expect_identical(read_qaplib(file)$solution, 1:2)
  writeLines("2 4 2 1", solution_file)
  expect_identical(read_qaplib(file)$solution, 2:1)
  writeLines("3 4 1 2", solution_file)
  expect_error(read_qaplib(file), "solution data")
  writeLines("2 4 1", solution_file)
  expect_error(read_qaplib(file), "solution data")
  writeLines("2 4 1 1", solution_file)
  expect_error(read_qaplib(file), "solution permutation")
  writeLines("2 4 1 1.5", solution_file)
  expect_error(read_qaplib(file), "solution permutation")
})

test_that("the zero-based bundled solution is usable in R", {
  p <- read_qaplib(system.file("qaplib", "tai40a.dat", package = "qap"))
  expect_identical(sort(p$solution), seq_len(nrow(p$A)))
  expect_equal(qap.obj(p$A, p$B, p$solution), p$opt)
})

# qap 0.2.0 (unreleased)

* Added the robust tabu search heuristic of Taillard (1991) as `qap(method = "RoTS")`.
* With `verbose = TRUE`, both solvers print their parameter settings and the run time of each restart. 
* Added a vignette comparing the run time and solution quality of both solvers.

# qap 0.1-3 (2026-09-30)

* Moved package documentation to roxygen2 and corrected documentation text and links.
* Added input validation for QAP matrices, permutations, and simulated annealing settings.
* Improved QAPLIB file validation and converted zero-based solutions to R's one-based indexing.
* Expanded tests for invalid inputs and bundled QAPLIB instances.

# qap 0.1-2 (2022-06-27)

* Fixed FORTRAN 2018 issues.

# qap 0.1-1 (2017-02-26)
  
* Fixed reading the optimal solution in read_qaplib.
* Added test.
* Native routines are now registered.

# qap 0.1-0 (2015-10-05)

* Initial release.

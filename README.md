
# R package qap - Heuristics for the Quadratic Assignment Problem (QAP)

[![CRAN
version](http://www.r-pkg.org/badges/version/qap)](https://CRAN.R-project.org/package=qap)
[![stream r-universe
status](https://mhahsler.r-universe.dev/badges/qap)](https://mhahsler.r-universe.dev/ui#package:qap)
[![CRAN RStudio mirror
downloads](http://cranlogs.r-pkg.org/badges/qap)](https://CRAN.R-project.org/package=qap)

Implements heuristics for the Quadratic Assignment Problem (QAP).
Currently only the simulated annealing heuristic described in Burkard
and Rendl (1984) is available.

## Installation

**Stable CRAN version:** Install from within R with

``` r
install.packages("qap")
```

**Current development version:** Install from
[r-universe.](https://mhahsler.r-universe.dev/ui#package:qap)

``` r
install.packages("qap", repos = "https://mhahsler.r-universe.dev")
```

## Usage

Load the had12 QAPLIB problem (shipped with the package). The problem
contains the A and B matrices and the optimal solution. We run 10
repetitions and use the best solution.

``` r
library(qap)
set.seed(1000)

p <- read_qaplib(system.file("qaplib", "had20.dat", package = "qap"))
p$opt
```

    ## [1] 6922

``` r
a <- qap(p$A, p$B, rep = 10)
a
```

    ##  [1]  8 15 16 14 19  6  7 12  1 11 10  5  3 20  2 17  4  9 18 13
    ## attr(,"obj")
    ## [1] 6926

Compare with known optimum (% above optimum).

``` r
(attr(a, "obj") - p$opt)/p$opt * 100
```

    ## [1] 0.058

## References

-   R.E. Burkard and F. Rendl. A thermodynamically motivated simulation
    procedure for combinatorial optimization problems. *European Journal
    of Operations Research,* 17(2):169-174, 1984.
-   [qap reference
    manual](https://cran.r-project.org/package=qap/qap.pdf)

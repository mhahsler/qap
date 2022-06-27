
# R package qap - Heuristics for the Quadratic Assignment Problem (QAP)

[![CRAN
version](http://www.r-pkg.org/badges/version/qap)](https://CRAN.R-project.org/package=qap)
[![stream r-universe
status](https://mhahsler.r-universe.dev/badges/qap)](https://mhahsler.r-universe.dev/ui#package:qap)
[![CRAN RStudio mirror
downloads](http://cranlogs.r-pkg.org/badges/qap)](https://CRAN.R-project.org/package=qap)

This package implements heuristics for the Quadratic Assignment Problem
(QAP) first introduced by Koopmans and Beckmann (1957). Although, the
QAP was introduced as a combinatorial optimization problem for the
facility location problem in operations research, it also has many
applications in data analysis (see Hubert and Schultz; 1976).

The problem is NP-hard and the package implements the simulated
annealing heuristic described in Burkard and Rendl (1984).

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

-   Hahsler M (2017). *qap: Heuristics for the Quadratic Assignment
    Problem (QAP)*. R package version 0.1-1,
    <https://github.com/mhahsler/qap>.
-   R.E. Burkard and F. Rendl (1984). A thermodynamically motivated
    simulation procedure for combinatorial optimization problems.
    *European Journal of Operations Research,* 17(2):169-174.
    <https://doi.org/10.1016/0377-2217(84)90231-5>
-   Koopmans TC, Beckmann M (1957). Assignment problems and the location
    of economic activities. *Econometrica* 25(1):53-76.
    <https://doi.org/10.2307/1907742>
-   Hubert, L., and Schultz, J. (1976). Quadratic assignment as a
    general data analysis strategy. *British Journal of Mathematical and
    Statistical Psychology,* 29(2), 190–241.
    <https://doi.org/10.1111/j.2044-8317.1976.tb00714.x>
